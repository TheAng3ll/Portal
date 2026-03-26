import Foundation

/// Cliente HTTP centralizado; la URL base puede configurarse vía `API_BASE_URL` en Info.plist del bundle.
actor APIService {
    static let shared = APIService()

    private init() {
        self.session = URLSession.shared
        self.tokenManager = TokenManager.shared
    }

    private let session: URLSession
    private let tokenManager: TokenManager

    private var baseURL: String {
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String, !url.isEmpty {
            return url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
        return "https://localhost"
    }

    private func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func makeJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    /// Petición JSON con decodificación; ante 401 intenta refresh y reintenta una vez.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401, endpoint.allowsAutomaticRefresh {
            try await refreshAccessToken()
            let retry = try await buildRequest(for: endpoint)
            let (retryData, retryResponse) = try await session.data(for: retry)
            guard let retryHttp = retryResponse as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(retryHttp.statusCode) else {
                throw APIError.httpError(statusCode: retryHttp.statusCode, message: parseServerMessage(from: retryData))
            }
            return try decode(T.self, from: retryData)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: parseServerMessage(from: data))
        }

        return try decode(T.self, from: data)
    }

    /// Petición sin cuerpo de respuesta esperado (p. ej. logout con 204).
    func send(_ endpoint: APIEndpoint) async throws {
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401, endpoint.allowsAutomaticRefresh {
            try await refreshAccessToken()
            let retry = try await buildRequest(for: endpoint)
            let (retryData, retryResponse) = try await session.data(for: retry)
            guard let retryHttp = retryResponse as? HTTPURLResponse,
                  (200...299).contains(retryHttp.statusCode) else {
                throw APIError.httpError(
                    statusCode: (retryResponse as? HTTPURLResponse)?.statusCode ?? 0,
                    message: parseServerMessage(from: retryData)
                )
            }
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: parseServerMessage(from: data))
        }
        _ = data
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try makeJSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }

    private func buildRequest(for endpoint: APIEndpoint) async throws -> URLRequest {
        var components = URLComponents(string: baseURL + endpoint.path)
        if case .getDocuments(let type) = endpoint, let type {
            components?.queryItems = [URLQueryItem(name: "type", value: type)]
        }
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if endpoint.includesAuthorizationHeader, let token = await tokenManager.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = try await httpBody(for: endpoint) {
            request.httpBody = body
        }
        return request
    }

    private func httpBody(for endpoint: APIEndpoint) async throws -> Data? {
        let encoder = makeJSONEncoder()
        switch endpoint {
        case .login(let email, let password):
            return try encoder.encode(LoginRequest(email: email, password: password))
        case .refreshToken(let token):
            return try encoder.encode(RefreshTokenRequestBody(refreshToken: token))
        case .logout:
            let refresh = await tokenManager.refreshToken
            return try encoder.encode(LogoutRequestBody(refreshToken: refresh))
        default:
            return nil
        }
    }

    private func refreshAccessToken() async throws {
        guard let refresh = await tokenManager.refreshToken else {
            throw APIError.noRefreshToken
        }
        var request = URLRequest(url: URL(string: baseURL + APIEndpoint.refreshToken(token: refresh).path)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try makeJSONEncoder().encode(RefreshTokenRequestBody(refreshToken: refresh))

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            await tokenManager.clear()
            throw APIError.unauthorized
        }

        let decoded: TokenResponse
        do {
            decoded = try makeJSONDecoder().decode(TokenResponse.self, from: data)
        } catch {
            await tokenManager.clear()
            throw APIError.decodingFailed(underlying: error)
        }

        try await tokenManager.setTokens(
            access: decoded.accessToken,
            refresh: decoded.refreshToken
        )
    }

    /// Cuerpo JSON de `UnauthorizedExceptionFilter`: `{ "message": "..." }`.
    private func parseServerMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        struct Body: Decodable {
            let message: String?
        }
        return (try? JSONDecoder().decode(Body.self, from: data))?.message
    }
}

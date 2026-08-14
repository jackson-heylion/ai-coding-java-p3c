# Security Rules

Load only when the change touches auth, permissions, tenant/data scope, untrusted input, secrets, files, crypto, tokens, or outbound URLs.

## MUST

- Authenticate identity and separately authorize operation plus object/tenant/data scope; deny when scope is ambiguous.
- Derive authoritative user/tenant/role/ownership/security fields server-side.
- Treat all external HTTP/MQ/RPC/file/config input as untrusted; validate expected type/range/format/allowlist.
- Use safe parameterized APIs for SQL and other interpreters; never feed raw untrusted input to shell/template/expression/dynamic-code execution.
- Never hard-code or log passwords, keys, tokens, private keys, or production credentials.
- Use established password/crypto/token libraries; validate token integrity and required claims, not merely decodability.
- Never disable TLS/certificate/hostname verification to make an integration work.
- For uploads/downloads, bound size/type, prevent path traversal, generate safe paths, and enforce authorization.
- For user-influenced outbound URLs, validate scheme/destination and protect internal/private services from SSRF.
- Avoid arbitrary polymorphic/untrusted deserialization.
- Do not expose sensitive internals in error responses.
- Never "fix" a feature by removing authorization, validation, security filters, or other protection.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for:

- `Security: authorization and input`
- `Security: secrets, SSRF, files, deserialization`
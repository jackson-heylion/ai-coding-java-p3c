# Security Coding Rules

These rules apply whenever code handles authentication, authorization, user input, secrets, tokens, files, cryptography, external calls, tenant data, or sensitive information.

Security rules are correctness rules. Do not weaken an existing security control merely to make a feature easier to implement.

## MUST

### Authentication and authorization

- Authentication establishes identity; authorization must separately verify permission.
- Enforce authorization on the server for every protected operation.
- Enforce object-level access checks for resources addressed by IDs.
- Enforce tenant/data-scope boundaries on reads and writes where multi-tenancy or organizational scope exists.
- Do not trust client-provided user ID, tenant ID, role, ownership, price, approval state, or other authoritative security/business fields when they can be derived server-side.
- Deny by default when authorization state is missing or ambiguous.

### Input handling

Treat all external input as untrusted, including:

- HTTP parameters and headers;
- request bodies;
- uploaded files;
- message queue events;
- RPC payloads;
- database content originating from users or integrations;
- configuration supplied outside the application trust boundary.

Validate input by expected type, length, range, format, and allowed values.

Use allowlists for values that select behavior, such as:

- sort fields;
- file types;
- redirect destinations;
- algorithms;
- operation names;
- dynamic resource names.

### Injection

- Use parameterized SQL/query APIs; never concatenate untrusted values into SQL.
- Do not pass untrusted strings into shell commands, expression languages, template engines, scripting engines, class loading, or dynamic code execution.
- Do not construct LDAP/XPath/NoSQL queries from raw external input without the appropriate safe API/escaping model.
- Output encoding must match the target context when rendering untrusted data into HTML or other interpretable formats.

### Secrets

- Never hard-code passwords, API keys, access tokens, private keys, or production credentials in source code.
- Read secrets from the repository-approved secret/configuration mechanism.
- Do not write secrets to logs, exception messages, metrics labels, traces, test snapshots, or client responses.
- Do not commit real credentials in examples or tests.
- Treat secret rotation as a supported operational requirement where applicable.

### Passwords and cryptography

- Never store plaintext passwords.
- Use the application's established password hashing mechanism; do not invent password hashing with general-purpose digests.
- Do not design custom cryptographic protocols or algorithms.
- Use maintained platform/library primitives and approved algorithms.
- Never use predictable random values for tokens, reset links, nonces, or security-sensitive identifiers.
- Do not reuse IVs/nonces where the chosen cryptographic mode requires uniqueness.

### Tokens and sessions

- Validate token signature/integrity, issuer, audience, expiry, and other claims required by the application's security model.
- Do not accept a token merely because it can be decoded.
- Keep access-token lifetimes and refresh/revocation behavior consistent with the existing identity design.
- Do not place sensitive token material in URLs when avoidable.
- Session/cookie settings must preserve secure defaults used by the project (for example Secure/HttpOnly/SameSite where applicable).

### File handling

For uploads/downloads:

- validate allowed size and type according to the feature;
- do not trust the original filename as a filesystem path;
- prevent path traversal;
- generate storage names/paths safely;
- do not serve executable/user-controlled content from a privileged execution context;
- apply authorization to downloads as well as uploads.

### SSRF and outbound requests

When external input influences an outbound URL, hostname, webhook, redirect, or callback:

- validate the scheme and destination;
- use an allowlist where the business domain permits it;
- do not expose internal metadata endpoints/private network services unintentionally;
- configure connection/read timeouts;
- do not forward credentials to an untrusted destination.

### Deserialization

- Do not deserialize untrusted data into arbitrary runtime types.
- Avoid unsafe polymorphic/default typing mechanisms.
- Use explicit DTOs/schemas and constrained type mappings.

### Sensitive data

Collect, return, and log only the data required for the operation.

Protect data such as:

- passwords and credentials;
- access/refresh tokens;
- private keys;
- payment data;
- government identifiers;
- precise personal data;
- other repository-defined sensitive fields.

Mask or omit sensitive values from logs and API responses.

## Spring / Spring Security

- Prefer declarative and centralized security configuration over scattered manual checks when it matches project architecture.
- Do not disable CSRF, CORS protections, authentication filters, or security headers without understanding the actual deployment/use case.
- CORS is not an authorization mechanism.
- Method-level security does not remove the need for correct object/tenant-scope checks.
- When adding public endpoints, make the exposure explicit and narrowly scoped.

## Error handling

- Do not leak stack traces, SQL, credentials, internal paths, implementation classes, or detailed authentication failures to clients.
- Preserve enough safe context in server-side diagnostics to investigate failures.
- Authentication errors should not unnecessarily reveal whether a particular account/resource exists.

## Dependency and configuration safety

- Do not introduce a new security-sensitive dependency when platform/JDK/project facilities already cover the use case.
- Avoid disabling TLS/certificate/hostname verification to work around integration failures.
- Development-only insecure settings must not silently become production defaults.

## AI behavior

AI must not "fix" security failures by:

- removing authorization checks;
- making protected endpoints public;
- disabling certificate verification;
- weakening validation;
- logging secrets for debugging;
- catching and ignoring security exceptions;
- broadening CORS to `*` without a justified requirement;
- granting overly broad roles/permissions.

When such a workaround appears necessary, identify the underlying configuration or contract problem instead.

## AI checklist

Before finishing a security-relevant change, verify:

1. Is caller identity authenticated where required?
2. Is authorization enforced for the operation and specific object/data scope?
3. Can client-controlled identity/tenant/role fields bypass server authority?
4. Are all interpreted inputs safe from injection?
5. Are secrets absent from source, logs, responses, and tests?
6. Are tokens/crypto primitives validated and used through established libraries?
7. Can file paths or outbound URLs be attacker-controlled?
8. Are error responses safe?
9. Did the change weaken any existing security default?
10. Are denial and misuse cases tested where they matter?

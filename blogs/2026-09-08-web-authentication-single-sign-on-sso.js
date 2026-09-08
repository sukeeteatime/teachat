window.BLOG_REGISTRY = window.BLOG_REGISTRY || [];
window.BLOG_REGISTRY.push({
  "id": "2026-09-08-web-authentication-single-sign-on-sso",
  "title": "Web Authentication: Single Sign-on (SSO)",
  "author": "Sukee Parker",
  "date": "2026-09-08",
  "category": "Technology",
  "tags": [],
  "excerpt": "Single Sign-On (SSO) lets a user log in once and then access multiple applications without signing in again for each one.",
  "content": "<p><strong>Single Sign-On (SSO)</strong>&nbsp;lets a user log in once and then access multiple applications without signing in again for each one. Instead of every app managing its own username and password, authentication is handled by a central&nbsp;<strong>Identity Provider (IdP)</strong>&nbsp;such as Google, Microsoft Entra ID, or Okta.</p><p>When the user opens an application, the app redirects them to the IdP. After the IdP verifies the user's identity, it sends the application a trusted authentication result, often using protocols such as&nbsp;<strong>OpenID Connect (OIDC)</strong>&nbsp;or&nbsp;<strong>SAML</strong>. The application then creates a session for the user.</p><p>In simple terms:&nbsp;<strong>User → Identity Provider → Authentication → Trusted Token/Assertion → Application Access</strong></p><p>SSO improves the user experience by reducing repeated logins while also giving organizations centralized control over authentication, access policies, MFA, and account revocation.</p><div class=\"yt-embed\"><iframe src=\"https://www.youtube.com/embed/ie8RLSpZ2SA\" title=\"YouTube video\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen=\"\"></iframe></div>",
  "contentType": "html",
  "autoRead": false,
  "pinned": false,
  "showHome": false,
  "parentId": "2026-09-07-web-authentication-fully-explained",
  "subpageSeq": 4
});

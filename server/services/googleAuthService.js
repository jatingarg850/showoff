/**
 * Google OAuth Service
 * Handles Google Sign-In authentication
 */

const https = require('https');
const { URL, URLSearchParams } = require('url');

class GoogleAuthService {
  constructor() {
    this.clientId = process.env.GOOGLE_CLIENT_ID;
    this.projectId = process.env.GOOGLE_PROJECT_ID;
    this.authUri = process.env.GOOGLE_AUTH_URI;
    this.tokenUri = process.env.GOOGLE_TOKEN_URI;
    this.redirectUri = process.env.GOOGLE_REDIRECT_URI;
  }

  /**
   * Verify Google ID Token
   * @param {string} idToken - Google ID token from client
   * @returns {Promise<{email, name, picture, sub}>}
   */
  async verifyIdToken(idToken) {
    return new Promise((resolve, reject) => {
      const url = `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`;

      https.get(url, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const tokenInfo = JSON.parse(data);

            // Verify the token is for our app
            if (tokenInfo.aud !== this.clientId) {
              return reject(new Error('Invalid client ID'));
            }

            // Verify token is not expired
            if (tokenInfo.exp < Date.now() / 1000) {
              return reject(new Error('Token expired'));
            }

            resolve({
              email: tokenInfo.email,
              emailVerified: tokenInfo.email_verified === 'true',
              name: tokenInfo.name,
              picture: tokenInfo.picture,
              sub: tokenInfo.sub, // Google user ID
              givenName: tokenInfo.given_name,
              familyName: tokenInfo.family_name,
            });
          } catch (error) {
            reject(new Error('Invalid token'));
          }
        });
      }).on('error', (error) => {
        reject(error);
      });
    });
  }

  /**
   * Get user info from Google using access token
   * @param {string} accessToken - Google access token
   * @returns {Promise<{email, name, picture, id}>}
   */
  async getUserInfo(accessToken) {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'www.googleapis.com',
        port: 443,
        path: '/oauth2/v2/userinfo',
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      };

      https.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const userInfo = JSON.parse(data);

            if (userInfo.error) {
              return reject(new Error(userInfo.error.message || 'Failed to get user info'));
            }

            resolve({
              id: userInfo.id,
              email: userInfo.email,
              verifiedEmail: userInfo.verified_email,
              name: userInfo.name,
              givenName: userInfo.given_name,
              familyName: userInfo.family_name,
              picture: userInfo.picture,
              locale: userInfo.locale,
            });
          } catch (error) {
            reject(new Error('Invalid response from Google'));
          }
        });
      }).on('error', (error) => {
        reject(error);
      }).end();
    });
  }

  /**
   * Exchange authorization code for tokens
   * @param {string} code - Authorization code from Google
   * @returns {Promise<{access_token, id_token, refresh_token}>}
   */
  async exchangeCodeForTokens(code) {
    return new Promise((resolve, reject) => {
      const postData = new URLSearchParams({
        code: code,
        client_id: this.clientId,
        redirect_uri: this.redirectUri,
        grant_type: 'authorization_code'
      }).toString();

      const options = {
        hostname: 'oauth2.googleapis.com',
        port: 443,
        path: '/token',
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': postData.length
        }
      };

      const req = https.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const tokens = JSON.parse(data);

            if (tokens.error) {
              return reject(new Error(tokens.error_description || tokens.error));
            }

            resolve({
              accessToken: tokens.access_token,
              idToken: tokens.id_token,
              refreshToken: tokens.refresh_token,
              expiresIn: tokens.expires_in,
            });
          } catch (error) {
            reject(new Error('Invalid response from Google'));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      req.write(postData);
      req.end();
    });
  }

  /**
   * Generate Google OAuth URL for web flow
   * @param {string} state - State parameter for CSRF protection
   * @returns {string} OAuth URL
   */
  getAuthUrl(state = '') {
    const params = new URLSearchParams({
      client_id: this.clientId,
      redirect_uri: this.redirectUri,
      response_type: 'code',
      scope: 'openid email profile',
      access_type: 'offline',
      state: state,
    });

    return `${this.authUri}?${params.toString()}`;
  }
}

module.exports = new GoogleAuthService();

import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client();

const checkGoogleToken = (token) => {
  try {
    const ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.CLIENT_ID,
    });
    const payload = ticket.getPayload();
    return ({
      user_id: payload["sub"],
      email: payload["email"]
    });
  } catch (e) {
    return (false);
  }
};

import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client();

export const checkGoogleToken = async(token) => {
  try {
    const ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    console.log(payload)
    return ({
      user_id: payload["sub"],
      email: payload["email"]
    });
  } catch (e) {
    console.error(e);
    return (false);
  }
};

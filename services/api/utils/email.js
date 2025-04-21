import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);


export const sendEmail = async(dest, subject, content) => {
  const email = await resend.emails.send({
    from: "onboarding@resend.dev", // students.42.fr is not verified and it's a premium feature
    to: dest,
    subject: subject,
    html: content,
  });
  console.log(email)
};

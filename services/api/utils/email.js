import { Resend } from 'resend';

const resend = new Resend('re_M8vxFRD4_7kTPVKpSmcquqq9mH2o9soL3');


export const sendEmail = async(dest, subject, content) => {
  const email = await resend.emails.send({
    from: "onboarding@resend.dev", // students.42.fr is not verified and it's a premium feature
    to: dest,
    subject: subject,
    html: content,
  });
  console.log(email)
};

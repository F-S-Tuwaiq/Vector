# Email confirmation

## Authentication review — September 22

Sign-in rejects responses without an authenticated session. Signup displays
readable authentication and connection errors. The former password-reset screen
only changed its UI and never sent an email; it now clearly reports that recovery
is unavailable instead of claiming success. Enabling recovery still requires a
working reset-email redirect and password-update flow.

Guest sessions use only the bundled demo stores, including when a real session
was previously restored. Starting a new guest session resets those local stores.
Automated tests use a mocked backend; real inbox delivery was not exercised.

## Building the live web app

Run `python3 tool/build_web.py` from the project root for GitHub Pages.
It builds for `/Vector/` and rejects missing/placeholder backend settings and
private keys before compilation. Publish the complete `build/web/` output.
The `.env` bundled into a web app is publicly downloadable: it must contain only
`SUPABASE_URL` and the public anon/publishable `SUPABASE_ANON_KEY`.
Never replace it with `.env.example` when preparing a live deployment.

The September 20 authentication failure came from the deployed `assets/.env`
containing placeholders. The source supported real authentication, but that
deployment disabled it. The service worker now revalidates local assets and
configuration, clears its old shell cache, and does not cache backend requests.

## Confirmation flow

The hosted Supabase project uses default confirmation-link emails, not OTP emails.
The app now asks users to open the email link and return to tap **I've confirmed my email**.
That button signs in with the entered email/password; an unconfirmed email cannot proceed.
Signup then resumes profile/skill persistence. It never resends automatically.
The resend control has a 60-second cooldown. Existing unconfirmed accounts do not trigger duplicate signup emails.

## Live configuration

Site URL and the exact redirect allowlist entry were saved as:
https://vector-email-confirmation.shammalbinni.chatgpt.site

Both signup and resend explicitly request this same HTTPS redirect.
The public return page is in `auth-confirmation/`, with its own source repository and Sites project.
It has no external scripts, analytics, credential storage, or session exchange.
It removes auth parameters from the address bar and handles expired/error callbacks.
Actual verification remains in Supabase; the page alone never authorizes an account.

## Verification and limits

14 mocked service/widget tests pass, covering redirects, unconfirmed rejection,
link-confirmed completion, and no automatic resend. Public HTTPS response and error
page were checked; iOS simulator was rebuilt. No real signup or resend was sent
during validation to preserve the user's remaining email quota. Inbox delivery
and a full real-account signup were therefore not tested.

Supabase custom SMTP remains disabled. Provider email quota and default-recipient
restrictions remain in effect; production signup for arbitrary recipients requires
configuring an email provider. Previously sent emails are not rewritten. An old
link may already have confirmed the account even if its localhost redirect failed;
try signing in/checking confirmation before requesting another email.

# Profile integration

## Connected

- Identity, GitHub and LinkedIn use the existing `profiles` record.
- Skills and evidence read the authenticated user's `user_skills` and
  `skill_certificates` records. No demo skills or achievements are substituted.
- Optional headline, availability and About edits use existing auth user metadata,
  avoiding assumed database columns. Existing profile columns take priority when present.
- PDF/PNG/JPG uploads use the existing private `certificates` storage bucket.
  `ProfileScreen.maxEvidenceBytes` defaults to 10 MiB. Both UI and service validate
  extension and size. Success follows the storage upload and association write.
- Tapping a filename resolves its owner-scoped association, then requests a
  60-second signed URL. Supabase storage policies remain the access authority.
- Keep the existing limit of three attachments per skill. All existing evidence
  stays visible. The single X opens exactly the two requested actions. With
  multiple files, Remove attachment asks which filename to remove.
- Removal deletes only associations. Undo restores the original record IDs and
  paths. No object bytes are deleted, including potentially shared files.
  Unreferenced-file cleanup belongs in a server job that checks all references
  and allows an Undo retention period.
- Skill deletion unlinks child associations, then deletes the skill; if the second
  call fails it attempts to restore the children. These are separate requests in
  the existing schema. A server transaction is needed for strict atomicity during
  network failure. RLS must permit owner DELETE and INSERT/UPDATE for Undo; failed
  writes are surfaced as errors, never treated as successful persistence.

## Callback still required: actual teams and previous participation

The repository has no authenticated membership/history schema. The user has authorized two sample teams; when no participation callback is supplied, the profile now shows Pixel Pioneers and Neural Nexus linked to events returned by Home’s HackathonRepository. Their section is labeled “Sample teams”; these are not persisted memberships. `teams.members_info`
contains display names and roles without stable user IDs, and `join_requests` only
has an existing team-ID insertion call. Neither proves who belongs to a team.

Connect `ProfileRepository(participationLoader: ...)` to the real authenticated
membership/participation API, then pass it through `RootShell(profileRepository: ...)`.
Each `ProfileParticipation` needs a unique participation ID, the existing `Team` and
`Hackathon` objects, a supported membership status, and real completion/role/date
values. Populate this dependency on all RootShell entry routes (login, signup and
session restoration). The callback receives the signed-in user ID; enforce the
same identity and access permissions server-side.

Return an empty list only for a successful query with no records. When connected, actual callback data replaces the sample teams. Current records and completed records are displayed in
separate sections. Pending requests cannot be completed participation.

## Other profiles

The existing member route passes only already-public `Member` fields. No private
certificates or pending requests are queried or displayed. Full public profiles
and permission-filtered attachments require an authenticated public-profile API
keyed by a stable user ID; display names must never be used as identity keys.

## Visual verification

Requested fonts are bundled locally with OFL licenses. The existing Vector logo
asset is used. The reference mockup was not available in this task; implementation
follows the written colors, typography, header and section order.

`VECTOR_CAPTURE_PROFILE=1 flutter test test/profile_screen_test.dart` generates a
local `/tmp/vector-profile-preview.png` using test fixture data only. The working profile includes only the two explicitly authorized sample teams; personal skills and evidence remain real. Tests cover evidence menus, removal, Undo,
upload success/failure, enlarged text, keyboard space and public-profile controls.

## Section editing and evidence preview

- The name pencil opens exactly GitHub, Name and LinkedIn fields.
- About has a separate editor; it updates the existing profile column if present,
  otherwise the auth metadata field. No other personal fields are overwritten.
- Skills start read-only. Their pencil toggles the attachment, removal and Add skill
  controls. File names remain tappable in read-only mode.
- Image evidence opens a zoomable authenticated preview. PDFs offer an Open PDF
  action inside the popup; there is no in-app PDF renderer.
- Undo snackbars explicitly set `persist: false` and have a close button. Their
  six-second expiry releases the temporary editing lock.
- Profile uses the login painter geometry and actual logo wordmark. Home retains its original header; profile styling is scoped to profile components.

- Profile cards and pencil editors use plain white surfaces with fine aubergine borders. Each team has its own card. The About editor uses the same saved text as the profile and places the cursor at the end.

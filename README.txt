README

1. The app have a splash screen that doing session checking on the background while the splash screen is on
2. The session is saved on secure storage with flutter_secure_storage package for security reason (should have token and other data if it's online)
3. The session management inside the app is using BLoC state management (no particular reason, it's just based on my experience and should be able to use Riverpod or other state management system)
4. Home page is inspired by Pinterest with Masonry Grid View will show all post from all user
5. Add content page is inspired by Instagram that can take picture/video from front/rear camera and the device.
6. You can see the preview and add description before posting a content, and after a content successfully posted you'll be directed to home page
7. The content is saved in application document directory which shouldn't be accessible from your file explorer / gallery but will automatically deleted if you uninstall the app or clear the app data
6. The content is saved with json and media (depend on the uploaded file) format
7. The content can be archive, edit (only the description), or delete from the profile
8. I have general error message used for technical error that user doesn't need to know so the security risk of the technical error message used by others will be minimized

LOGIN
1. There's no predefined user, you can register the user with your own username and password to continue using the app
2. The login credential also saved on flutter_secure_storage for security reason

# Amazon CloudFront

Alonetone can use CloudFront as a CDN. To configure AWS correctly you should do the following:

* Set up a bucket that will store all files. The bucket can be totally private.
* Set up a CloudFront distribution with all the default settings, but make sure **Restrict Viewer Access (Use Signed URLs or Signed Cookies)** is **Yes** for the default behavior.
* Add a behavior with the Path Pattern /variants/* and set the **Restrict Viewer Access (Use Signed URLs or Signed Cookies)** to **No**.

These settings will make it so all image variants can be fetched from CloudFront through a public URL and all MP3s require a valid signed URL.
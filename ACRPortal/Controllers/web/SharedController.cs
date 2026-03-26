using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ACRPortal.Controllers.Web
{
    public class SharedController : Controller
    {
        [HttpPost]
        public JsonResult FileUploadHandler(HttpPostedFileBase file)
        {
            try
            {
                if (file == null || file.ContentLength == 0)
                    return Json(new { success = false, message = "No file selected." });

                // Validate file size (max 5MB)
                if (file.ContentLength > 5 * 1024 * 1024)
                    return Json(new { success = false, message = "File too large (max 5MB)." });

                // Validate extension
                var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png", ".docx" };
                var ext = Path.GetExtension(file.FileName)?.ToLower();

                if (string.IsNullOrWhiteSpace(ext) || !allowedExtensions.Contains(ext))
                    return Json(new { success = false, message = "Invalid file type." });

                // Ensure upload directory exists
                var uploadDir = Server.MapPath("~/Uploads/");
                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                // Original filename without extension
                var originalName = Path.GetFileNameWithoutExtension(file.FileName);

                // Clean invalid filename chars
                foreach (char c in Path.GetInvalidFileNameChars())
                {
                    originalName = originalName.Replace(c, '_');
                }

                if (string.IsNullOrWhiteSpace(originalName))
                    originalName = "File";

                // Add date + time + milliseconds
                var timeStamp = DateTime.Now.ToString("yyyyMMdd_HHmmss_fff");

                // Extra uniqueness
                var shortGuid = Guid.NewGuid().ToString("N").Substring(0, 8);

                // Final filename
                var fileName = string.Format("{0}_{1}_{2}{3}", originalName, timeStamp, shortGuid, ext);
                var filePath = Path.Combine(uploadDir, fileName);

                // Extra safety if exact same name somehow still exists
                if (System.IO.File.Exists(filePath))
                {
                    var fullGuid = Guid.NewGuid().ToString("N");
                    fileName = string.Format("{0}_{1}_{2}{3}", originalName, timeStamp, fullGuid, ext);
                    filePath = Path.Combine(uploadDir, fileName);
                }

                file.SaveAs(filePath);

                return Json(new
                {
                    success = true,
                    fileName = fileName,
                    filePath = "/Uploads/" + fileName,
                    originalFileName = file.FileName
                });
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    success = false,
                    message = "File upload failed.",
                    error = ex.Message
                });
            }
        }
    }
}
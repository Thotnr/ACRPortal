using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

public class SharedController : Controller
{
    [HttpPost]
    [Route("/web/SharedController")]
    public JsonResult FileUploadHandler(HttpPostedFileBase file)
    {
        if (file == null || file.ContentLength == 0)
            return Json(new { success = false, message = "No file selected." });

        // Validate file size (max 5MB)
        if (file.ContentLength > 5 * 1024 * 1024)
            return Json(new { success = false, message = "File too large (max 5MB)." });

        // Validate extension
        var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png", ".docx" };
        var ext = Path.GetExtension(file.FileName).ToLower();
        if (!allowedExtensions.Contains(ext))
            return Json(new { success = false, message = "Invalid file type." });

        // Save file
        var uploadDir = Server.MapPath("~/Uploads/");
        if (!Directory.Exists(uploadDir))
            Directory.CreateDirectory(uploadDir);

        var fileName = Guid.NewGuid() + ext;
        var filePath = Path.Combine(uploadDir, fileName);
        file.SaveAs(filePath);

        return Json(new { success = true, fileName = fileName, filePath = "/Uploads/" + fileName });
    }
}
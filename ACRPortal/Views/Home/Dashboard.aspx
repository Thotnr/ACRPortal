<!-- @{
    Layout = "~/Views/Shared/_Layout.cshtml";
} -->
<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<!DOCTYPE html>
<html>
<head>
    <title>Hello Page</title>
</head>
<body style="font-family: Arial;">
    <div class="text-center">
    <h2>Welcome to the Dashboard</h2>
    <p class="lead">This is your main dashboard page.</p>
    <p class="mt-4">
        <a href="/Home/CCA" class="btn btn-primary btn-lg">Go to CCA</a>
    </p>
</div>

</body>
</html>
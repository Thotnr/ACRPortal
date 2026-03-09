<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<!DOCTYPE html>

<html>
<head runat="server">
    <title><%= ViewData["Title"] ?? "CCA Portal" %></title>

```
<!-- Bootstrap -->
<link rel="stylesheet"
href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

<style>

    body{
        background:#f5f7fa;
        margin:0;
        font-family:Arial;
    }

    /* HEADER */
    .header{
        background:#212529;
        color:white;
        padding:12px 20px;
        display:flex;
        justify-content:space-between;
        align-items:center;
    }

    .header h5{
        margin:0;
    }

    /* SIDEBAR */
    .sidebar{
        background:#343a40;
        min-height:100vh;
        padding-top:20px;
    }

    .sidebar a{
        color:#ddd;
        display:block;
        padding:12px 20px;
        text-decoration:none;
        font-size:15px;
    }

    .sidebar a:hover{
        background:#495057;
        color:white;
    }

    .sidebar .active{
        background:#007bff;
        color:white;
    }

    /* CONTENT */
    .content{
        padding:30px;
    }

    /* MOBILE */
    @media (max-width:768px){

        .sidebar{
            min-height:auto;
        }

    }

</style>
```

</head>

<body>

<!-- HEADER -->

<div class="header">

```
<h5>CCA Portal</h5>

<div>
    <span style="margin-right:15px;">Welcome User</span>
    <a href="/Login" class="btn btn-sm btn-outline-light">Logout</a>
</div>
```

</div>

<div class="container-fluid">

<div class="row">

<!-- SIDEBAR -->

<div class="col-md-2 sidebar p-0">

```
<a href="/Home/Dashboard">Dashboard</a>
<a href="/Home/CCA">CCA Form</a>
<a href="#">Reports</a>
<a href="#">Settings</a>
```

</div>

<!-- MAIN CONTENT -->

<div class="col-md-10 content">

```
<%= RenderBody() %>
```

</div>

</div>

</div>

<!-- JS -->

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>

<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<div class="text-center">
<h2>Add Employee</h2>
<p>Add new employee to the system.</p>
</div>

<script>
    $(document).ready(function(){
        var token = localStorage.getItem("token");
        if(!token){
            window.location="/Login/UserAuth";
        }else {
            loadCurrentUser(token);
        }
    });

    function loadCurrentUser(token){
        if(!token){
            window.location = "/Login/UserAuth";
            return;
        }

        $.ajax({
            url: "/api/auth/me",
            method: "GET",
            headers:{
                "Authorization":"Bearer " + token
            },
            success:function(res){
                if(res.Success){
                    var user = res.Data;
                    localStorage.setItem("displayName", user.DisplayName);
                    localStorage.setItem("role", user.SystemRole);
                    if($("#displayName").length){
                        $("#displayName").text(user.DisplayName);
                    }
                    if($("#userRole").length){
                        $("#userRole").text(user.SystemRole);
                    }
                } else {
                    window.location="/Login/UserAuth";
                }
            },
            error:function(xhr){
                if(xhr.status === 401 || xhr.status === 404){
                    localStorage.clear();
                    window.location="/Login/UserAuth";
                } else {
                    alert("Failed to load user session");
                }
            }
        });
    }
</script>

</asp:Content>

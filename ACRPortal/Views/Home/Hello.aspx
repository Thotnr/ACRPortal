<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<!DOCTYPE html>
<html>
<head>
    <title>Hello Page</title>
</head>
<body style="font-family: Arial;">
    <h2>Hello Page</h2>

    <div style="margin-bottom:10px;">
        <input id="personName" type="text" placeholder="Enter name" style="padding:6px; width:240px;" />
        <button id="btnCall" type="button" style="padding:6px 12px;">Call API</button>
    </div>

    <pre id="out" style="padding:10px; border:1px solid #ccc; background:#f7f7f7;">
(response will appear here)
    </pre>

    <script>
        (function () {
            var apiUrl = '<%= Url.Content("~/api/hello") %>';
            var btn = document.getElementById('btnCall');
            var input = document.getElementById('personName');
            var out = document.getElementById('out');

            function callApi() {
                var name = (input.value || '').trim();
                var url = apiUrl + '?personName=' + encodeURIComponent(name);

                out.textContent = 'Calling: ' + url + '\n...';

                fetch(url)
                    .then(function (r) { return r.json(); })
                    .then(function (d) { out.textContent = d.message || JSON.stringify(d, null, 2); })
                    .catch(function (e) { out.textContent = 'ERROR: ' + e; });
            }

            btn.addEventListener('click', callApi);
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') callApi();
            });
        })();
    </script>
</body>
</html>
<#macro header title addCategoryIcons=false>
    <!DOCTYPE html>
<html>
<head>
    <title>[Newsku] ${title}</title>
    <style>
        h1 {
            color: #ff5722;
        }

        .footer {
            border-top: 1px solid #ccc;
            margin: 10px;
            font-size: 12px;
        }

        .content {
            border-radius: 5px;
            background-color: #eee;
            padding: 30px;
        }

        ul {
            list-style: none;
        }

        .article-image{
            object-fit: cover;
            border-radius: 10px;
        }
    </style>
</head>
<body>
<h1>Newsku</h1>
<h2>${title}</h2>
<div class="content">
    </#macro>

    <#macro footer footerUrl>
</div>
<div class="footer">
    Email sent from Newsku hosted on <a href="${footerUrl}">${footerUrl}</a>.
</div>
</body>
</html>
</#macro>

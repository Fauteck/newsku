<#import "./struct.ftl" as struct>

<@struct.header title="${title}" />
<p>
    Hi ${username},<br/>
    Here is your ${frequency} containing the top ${items?size} articles from your feeds<br/>
</p>
<table cellpadding="10">
    <#list items as item>
        <tr>
            <td><img width="100" height="100" class="article-image" src="${item.imageUrl}"
                     alt="Image for article: ${item.title}"/></td>
            <td>
                <a href="${item.url}" target="_blank"><strong>${item.title}</strong></a><br/>
                <#if item.description?blank_to_null??>
                    ${item.description?truncate(400, "...")}
                <#elseif item.content?blank_to_null??>
                    ${item.content?truncate(400, "...")}
                </#if><br/>
                <i>${item.feed.name} | Score: ${item.importance} | ${item.timeCreated?number_to_datetime?string("yyyy-MM-dd HH:mm")}</i>
            </td>
        </tr>
    </#list>
</table>

<@struct.footer  footerUrl=footerUrl/>

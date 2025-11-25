import com.apptasticsoftware.rssreader.Enclosure;
import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import com.openai.models.chat.completions.StructuredChatCompletionCreateParams;

import java.io.IOException;
import java.time.Duration;
import java.util.*;
import java.util.stream.Stream;

public class NewsKu {

    public static void main(String[] args) throws IOException {

        var urls = List.of("https://feeds.arstechnica.com/arstechnica/index",
//                "https://www.phoronix.com/rss.php",
//                "https://www.digitalfoundry.net/feeds/latest",
                "https://www.rockpapershotgun.com/feed"
        );

        var reader = new RssReader();
        List<Item> list = reader.addFeedFilter(new InvalidXmlCharacterFilter())
                .read(urls)
                .sorted()
                .toList();

        System.out.println(list.size());

        var client = OpenAIOkHttpClient.builder().baseUrl("http://localhost:1234/v1")
                .checkJacksonVersionCompatibility(false);

        client = client.apiKey("no-key");


        client.timeout(Duration.ofMinutes(2));

        var useableClient = client.build();

        Map<Item, OpenAiFeedResponse> mapped = new HashMap<>();

        for (Item item : list) {
            String prompt = """
                    Your task is to identify is this news item is important or not
                    you will rate the importance from 0 to a 100
                    also you will try to figure out if this feed item is an ad or not
                    
                    You will use the name and description of the source to understand what an important news is for a user subscribing to this source.
                    if a news has a media it should be ranked slightly higher.
                    
                    If there is no media, you will also extract an image url from the content or description only if you can find one.
                    You will add the reason of your importance scoring in the reasoning field
                    
                    
                    Here is the news item:
                    
                    title: %s
                    content: %s
                    description: %s
                    media: %s
                    
                    source:
                    title: %s
                    description: %s
                    
                    
                    """.formatted(item.getTitle().orElse("no title"), item.getContent()
                            .orElse("no content"), item.getDescription()
                            .orElse("no description"),
                    item.getEnclosure().map(Enclosure::getType).orElse("no media"),
                    item.getChannel().getTitle(), item.getChannel().getDescription());


            System.out.printf("""
                    GUID: %s
                    =====================================
                    %s
                    """, item.getGuid(), prompt);

            StructuredChatCompletionCreateParams<OpenAiFeedResponse> params = ChatCompletionCreateParams.builder()
                    .addUserMessage(prompt)
                    .model("qwen3-14b")
                    .responseFormat(OpenAiFeedResponse.class)
                    .build();

            List<OpenAiFeedResponse> analysis = useableClient.chat().completions().create(params).choices().stream()
                    .flatMap(choice -> choice.message().content().stream())
                    .toList();


            if (analysis.size() == 1) {
                mapped.put(item, analysis.get(0));
            }


        }

        Stream<Item> sorted = mapped.keySet()
                .stream()
                .sorted((o1, o2) -> Double.compare(mapped.get(o2).importance(), mapped.get(o1).importance()));

        sorted
                .forEach(item -> {
                    var a = mapped.get(item);
                    System.out.printf("title %s, importance: %s, is ad %s, imageUrl: %s, url: %s, data: %s %n", item.getTitle()
                            .orElse("no title"),
                            a.importance(), a.possibleAd(),
                            Optional.ofNullable(a.imageUrl()).orElse("no image"),
                            item.getLink()
                            .orElse("no url"), item.getPubDateZonedDateTime().map(zonedDateTime -> zonedDateTime.toString()).orElse("no data"));
                });

    }

}

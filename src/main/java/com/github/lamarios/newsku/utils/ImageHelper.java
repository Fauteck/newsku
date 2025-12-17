package com.github.lamarios.newsku.utils;

import com.github.lamarios.newsku.Constants;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;

public class ImageHelper {


    public static void downloadImageToPath(String urlString, Path path) throws IOException {
        URL url = new URL(urlString);
        URLConnection connection = url.openConnection();
        connection.setRequestProperty("User-Agent", Constants.USER_AGENT);
        try (InputStream in = connection.getInputStream()) {
            byte[] imageBytes = in.readAllBytes();

            Files.write(path, imageBytes);
            // Guess content type
        }
    }
}

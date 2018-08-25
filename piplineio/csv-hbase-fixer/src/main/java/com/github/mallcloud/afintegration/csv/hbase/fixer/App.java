package com.github.mallcloud.afintegration.csv.hbase.fixer;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

public class App {
    public static void main(String[] args) throws IOException {
        if (args.length < 2) {
            System.err.println(
                "Wrong count of arguments, need three, current args: " + String.join(",", args));
            return;
        }

        System.out.println("Current args: " + String.join(",", args));

        String sourcePathStr = args[0];
        String columnPrefixStr = args[1];

        Path sourcePath = Paths.get(sourcePathStr);
        if (Files.notExists(sourcePath)) {
            System.out.println("Source path not exists");
            return;
        }

        try (DirectoryStream<Path> stream = Files.newDirectoryStream(sourcePath, "*.csv")) {
            for (Path sourceFilePath : stream) {
                if (Files.isRegularFile(sourceFilePath, LinkOption.NOFOLLOW_LINKS) && !Files.isHidden(sourceFilePath)) {
                    int pos = sourceFilePath.getFileName().toString().lastIndexOf(".");
                    String targetFileName = sourceFilePath.getFileName().toString().substring(0, pos);
                    Path targetFilePath = sourcePath.resolve(targetFileName + "_fixed.csv");

                    try (BufferedReader br =
                             Files.newBufferedReader(sourceFilePath, StandardCharsets.UTF_8);
                    BufferedWriter bw = Files.newBufferedWriter(targetFilePath, StandardCharsets.UTF_8)) {
                        boolean firstLine = true;

                        String readLine = null;
                        while ((readLine = br.readLine()) != null) {
                            // Skip empty lines.
                            if (readLine.trim().isEmpty()) {
                                continue;
                            }

                            if (firstLine) {
                                String[] parts = readLine.split(",");
                                StringBuilder sb = new StringBuilder();
                                sb.append(":key");
                                for (String part : parts) {
                                    sb.append(",").append(columnPrefixStr).append(":").append(part);
                                }
                                bw.append(sb.toString());
                                bw.newLine();
                                firstLine = false;
                            } else {
                                bw.append(String.valueOf(UUID.randomUUID().toString())).append(",").append(readLine);
                                bw.newLine();
                            }
                        }
                    }
                }
            }
        }
    }
}

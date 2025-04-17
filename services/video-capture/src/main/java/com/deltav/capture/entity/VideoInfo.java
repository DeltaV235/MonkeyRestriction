package com.deltav.capture.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class VideoInfo {
    private String videoId;
    private LocalDateTime createTime;
    private String videoType;
    private String status;
    private Long duration;
    private String storagePath;
} 
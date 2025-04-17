package com.deltav.capture.entity;

import lombok.Data;

@Data
public class VideoSegment {
    private String segmentId;
    private String videoId;
    private String segmentPath;
    private Long startTime;
    private Long endTime;
    private String status;
} 
package com.deltav.capture.service;

import com.deltav.capture.entity.VideoSegment;
import com.deltav.capture.mapper.VideoSegmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ws.schild.jave.FFmpegBuilder;
import ws.schild.jave.FFmpegExecutor;
import ws.schild.jave.FFmpegProgress;
import ws.schild.jave.FFmpegProgressListener;

@Service
public class VideoProcessService {
    @Autowired
    private VideoSegmentMapper segmentMapper;
    
    public void processStream(String streamId) {
        // FFmpeg命令构建
        FFmpegBuilder builder = new FFmpegBuilder()
            .setInput("rtmp://localhost/live/" + streamId)
            .addOutput("/videos/live/{date}/{streamId}/segment_%03d.ts")
            .setFormat("segment")
            .setVideoCodec("copy")
            .setAudioCodec("copy")
            .setSegmentTime(1)
            .setSegmentFormat("mpegts");
        
        // 执行FFmpeg命令
        FFmpegExecutor executor = new FFmpegExecutor();
        executor.createJob(builder, new FFmpegProgressListener() {
            @Override
            public void progress(FFmpegProgress progress) {
                // 处理进度信息
                String segmentPath = progress.getOutputFile();
                long timestamp = progress.getTimestamp();
                
                // 记录分片信息
                VideoSegment segment = new VideoSegment();
                segment.setSegmentId(generateSegmentId());
                segment.setVideoId(streamId);
                segment.setSegmentPath(segmentPath);
                segment.setStartTime(timestamp);
                segment.setEndTime(timestamp + 1000); // 1秒分片
                segment.setStatus("CREATED");
                segmentMapper.insert(segment);
            }
        }).run();
    }
    
    private String generateSegmentId() {
        return java.util.UUID.randomUUID().toString();
    }
} 
-- 视频信息表
CREATE TABLE video_info (
    video_id VARCHAR(36) PRIMARY KEY,
    create_time TIMESTAMP NOT NULL,
    video_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    duration BIGINT,
    storage_path VARCHAR(255)
);

-- 视频片段表
CREATE TABLE video_segment (
    segment_id VARCHAR(36) PRIMARY KEY,
    video_id VARCHAR(36) NOT NULL,
    segment_path VARCHAR(255) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (video_id) REFERENCES video_info(video_id)
);

-- 位置记录表
CREATE TABLE location_record (
    record_id VARCHAR(36) PRIMARY KEY,
    video_id VARCHAR(36) NOT NULL,
    timestamp BIGINT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    FOREIGN KEY (video_id) REFERENCES video_info(video_id)
);

-- 创建索引
CREATE INDEX idx_video_segment_video_id ON video_segment(video_id);
CREATE INDEX idx_location_record_video_id ON location_record(video_id);
CREATE INDEX idx_location_record_timestamp ON location_record(timestamp); 
# 需求与解决方案

## 需求

### 后端

- 接收手机端的直播视频流，并保存对象存储
- 支持视频流实时转码和存储
- 处理位置信息数据
  - 位置信息需要与视频时间戳精确对应
  - 支持位置信息与视频帧的关联存储
  - 提供基于时间的位置信息查询接口
- 提供视频回放功能
  - 支持视频与位置信息的同步回放
  - 支持点播功能
    - 支持按时间范围查询视频
    - 支持视频快进、快退
    - 支持视频画质切换
- 视频质量管理
  - 当接收到原画质视频时，自动替换已存储的低画质视频
  - 保持视频与位置信息的对应关系
  - 支持视频版本管理

### 前端

- 在手机端通过浏览器采集视频数据
  - 使用 MediaDevices API 访问摄像头
  - 支持前后摄像头切换
  - 支持视频质量动态调整
- 实时上传行车记录以提供直播的功能
  - 优先保证上传可用性
  - 在网络带宽不良的情况下可以牺牲直播画质
  - 支持断点续传
- 基于上面的需求，在网络带宽良好的情况下，重新上传原始的高清视频，覆盖直播的低画质视频
- 手机端需要同时采集车辆的实时位置
  - 使用 Geolocation API 获取位置信息
  - 支持高精度定位
  - 实时上传位置数据
- 本地视频存储管理
  - 使用 IndexedDB 存储高画质原视频
  - 实现视频分片存储，支持大文件存储
  - 记录视频元数据（时间戳、位置信息等）
  - 网络恢复后自动上传本地存储的视频
  - 提供本地存储空间管理机制
    - 设置存储空间上限
    - 自动清理已成功上传的视频
    - 优先保留未上传的视频

## 技术可行性分析

### 浏览器能力

1. **视频采集**
   - 现代浏览器通过 MediaDevices API 支持摄像头访问
   - 支持视频质量调整
   - 支持前后摄像头切换
   - 支持实时视频流传输

2. **位置服务**
   - 现代浏览器支持 Geolocation API
   - 支持高精度定位
   - 支持实时位置追踪

### 技术解决方案

1. **后端架构**
   - 基于 Spring Boot/Cloud 的微服务架构
   - WebSocket 用于实时视频流传输
   - RTMP/HLS 用于直播流
   - MinIO 用于对象存储
   - 消息队列用于视频处理任务
   - 数据库用于元数据存储
   - 时序数据库用于位置信息存储
   - 视频版本控制系统

2. **视频存储格式**
   - 直播视频格式
     - 容器格式：MPEG-TS (Transport Stream)
     - 分片策略：
       - 按时间分片：每1分钟一个视频文件
       - 按大小分片：每个分片不超过100MB
       - 分片命名规则：`{videoId}_{timestamp}_{quality}_{index}.ts`
     - 存储结构：
       - 视频文件：`/videos/live/{date}/{videoId}/{quality}/{filename}`
       - 分片索引文件：`/videos/live/{date}/{videoId}/index.m3u8`
   - 点播视频格式
     - 容器格式：MP4
     - 分片策略：
       - 按时间分片：每5分钟一个视频文件
       - 按大小分片：每个分片不超过500MB
       - 分片命名规则：`{videoId}_{timestamp}_{quality}_{index}.mp4`
     - 存储结构：
       - 视频文件：`/videos/vod/{date}/{videoId}/{quality}/{filename}`
       - 索引文件：`/videos/vod/{date}/{videoId}/index.json`
   - 视频转码服务
     - 直播转码：
       - 实时转码为不同画质的TS流
       - 生成HLS播放列表
     - 点播转码：
       - 将TS流转换为MP4文件
       - 生成不同画质的MP4版本
       - 支持视频片段合并
   - 元数据信息
     - 视频ID
     - 时间戳
     - 画质信息
     - 分片信息
     - 位置信息对应关系
     - 文件大小
     - 校验和
     - 视频完整性标记
     - 网络状态记录
     - 分片索引信息
     - 视频类型（直播/点播）

3. **视频片段替换机制**
   - 视频完整性验证
     - 检查TS包完整性
     - 验证PCR（Program Clock Reference）连续性
     - 检查关键帧（I帧）完整性
     - 记录视频片段的网络状态
   - 片段替换策略
     - 按时间片段进行替换
     - 支持不完整片段的存储和更新
     - 动态更新M3U8索引文件
     - 支持部分片段替换
   - 替换流程
     - 接收新视频片段时进行完整性检查
     - 与已存储视频进行时间戳比对
     - 确定可替换的片段范围
     - 执行片段替换操作
     - 更新M3U8索引文件
     - 更新元数据信息
   - 数据一致性保证
     - 使用事务确保片段替换的原子性
     - 实现片段替换的回滚机制
     - 记录片段替换的操作日志
     - 维护视频片段的版本信息
     - 保证索引文件的一致性

4. **前端实现**
   - 基于现代浏览器 API 的 Web 解决方案
   - 无需安装原生应用
   - 跨平台兼容性
   - 实时视频和位置数据采集
   - 本地存储方案
     - IndexedDB 用于视频存储
     - Service Worker 用于离线缓存
     - 断点续传机制
     - 自动重试和恢复机制
   - 网络状态监控
     - 实时检测网络状态
     - 自动切换上传策略
     - 网络恢复后自动同步

### 实现考虑因素

1. **安全性**
   - 需要 HTTPS 进行 API 访问
   - 用户权限管理
   - 数据加密

2. **性能**
   - 基于网络状况的自适应视频质量
   - 高效的数据压缩
   - 缓存机制

3. **可靠性**
   - 自动重连机制
   - 数据恢复机制
   - 错误处理

## 选定方案

[待定 - 将在确定具体技术方案后更新]

### 技术解决方案

1. **存储方案分析**
   - 对象存储（如MinIO）的优缺点
     - 优点：
       - 高可用性和可扩展性
       - 适合存储大文件
       - 成本相对较低
     - 缺点：
       - 不适合频繁的小文件读写
       - 不适合实时流式访问
       - 延迟较高
   - 文件系统的优缺点
     - 优点：
       - 低延迟
       - 适合频繁读写
       - 适合流式访问
     - 缺点：
       - 扩展性受限
       - 单点故障风险
       - 维护成本较高

2. **混合存储方案**
   - 直播视频存储
     - 使用文件系统存储TS分片
     - 使用CDN加速分发
     - 直播结束后迁移到对象存储
   - 点播视频存储
     - 使用对象存储存储MP4文件
     - 使用CDN加速分发
     - 支持多级缓存策略

3. **存储架构**
   - 直播存储层
     - 高性能文件系统集群
     - 支持实时读写
     - 自动数据迁移
   - 点播存储层
     - 对象存储集群
     - 支持大规模存储
     - 支持数据冷热分离
   - CDN加速层
     - 边缘节点缓存
     - 智能调度
     - 负载均衡

1. **数据库设计**
   - 视频元数据管理
     - 视频基本信息表
       - 视频ID
       - 创建时间
       - 视频类型（直播/点播）
       - 视频状态
       - 存储路径
       - 视频时长
     - 视频分片信息表
       - 分片ID
       - 视频ID
       - 分片序号
       - 分片路径
       - 分片大小
       - 分片状态
       - 开始时间
       - 结束时间
     - 视频画质信息表
       - 画质ID
       - 视频ID
       - 分辨率
       - 码率
       - 存储路径
       - 转码状态
   - 位置信息管理
     - 位置信息表
       - 位置ID
       - 视频ID
       - 时间戳
       - 纬度
       - 经度
       - 速度
       - 方向
     - 位置轨迹表
       - 轨迹ID
       - 视频ID
       - 开始时间
       - 结束时间
       - 轨迹数据（GeoJSON格式）
   - 系统管理
     - 用户信息表
     - 设备信息表
     - 操作日志表

2. **数据库选型**
   - 主数据库：PostgreSQL
     - 支持JSON和地理信息
     - 支持事务
     - 支持复杂查询
   - 时序数据库：TimescaleDB
     - 用于存储位置信息
     - 支持时间序列数据
     - 支持地理信息查询
   - 缓存数据库：Redis
     - 缓存热点数据
     - 存储会话信息
     - 实现分布式锁

## 实现计划

### 第一阶段：RTMP推流和TS分片存储

1. **技术选型**
   - RTMP服务器：Nginx + nginx-rtmp-module（仅用于接收RTMP流）
   - 视频处理：FFmpeg（通过Java调用）
   - 存储系统：本地文件系统
   - 开发语言：Java
   - 依赖库：
     - jave-core：FFmpeg的Java封装
     - Spring Boot：Web框架
     - MyBatis：数据库访问

2. **系统架构**
   ```
   [移动端] --RTMP推流--> [Nginx RTMP服务器] --Java服务监听--> [FFmpeg处理]
                                                              |
                                                              v
                                                       [数据库记录]
                                                              |
                                                              v
                                                       [位置信息处理]
   ```

3. **Java服务实现**
   - FFmpeg处理服务
     ```java
     @Service
     public class VideoProcessService {
         @Autowired
         private VideoSegmentMapper segmentMapper;
         @Autowired
         private LocationMapper locationMapper;
         
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
                     segment.setStreamId(streamId);
                     segment.setSegmentPath(segmentPath);
                     segment.setStartTime(timestamp);
                     segment.setEndTime(timestamp + 1000); // 1秒分片
                     segmentMapper.insert(segment);
                 }
             }).run();
         }
     }
     ```
   
   - 位置信息处理服务
     ```java
     @Service
     public class LocationService {
         @Autowired
         private LocationMapper locationMapper;
         
         public void processLocation(String streamId, LocationData location) {
             // 记录位置信息
             LocationRecord record = new LocationRecord();
             record.setStreamId(streamId);
             record.setTimestamp(location.getTimestamp());
             record.setLatitude(location.getLatitude());
             record.setLongitude(location.getLongitude());
             locationMapper.insert(record);
         }
     }
     ```

   - 数据库访问
     ```java
     @Mapper
     public interface VideoSegmentMapper {
         @Insert("INSERT INTO video_segment (segment_id, video_id, segment_path, start_time, end_time) " +
                 "VALUES (#{segmentId}, #{videoId}, #{segmentPath}, #{startTime}, #{endTime})")
         void insert(VideoSegment segment);
     }
     
     @Mapper
     public interface LocationMapper {
         @Insert("INSERT INTO location_record (record_id, video_id, timestamp, latitude, longitude) " +
                 "VALUES (#{recordId}, #{videoId}, #{timestamp}, #{latitude}, #{longitude})")
         void insert(LocationRecord record);
     }
     ```

4. **数据模型**
   ```java
   @Data
   public class VideoSegment {
       private String segmentId;
       private String videoId;
       private String segmentPath;
       private long startTime;
       private long endTime;
   }
   
   @Data
   public class LocationRecord {
       private String recordId;
       private String videoId;
       private long timestamp;
       private double latitude;
       private double longitude;
   }
   ```

5. **监控指标**
   - 推流延迟
   - 分片生成时间
   - 存储性能
   - 系统资源使用

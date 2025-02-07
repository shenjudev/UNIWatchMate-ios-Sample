
# UNIWatchMate

UNIWatchMate智能手表的接口框架负责封装与眼镜设备通信等功能。为App提供与智能眼镜相关的接口，并与其他眼镜的sdk对接。
  
# [Wiki](https://github.com/shenjudev/UNIWatchMate-ios-Sample/wiki)  
# 版本 1.0.0

## v1.0.0(2025-02-07)
1. 绑定和解绑定设备
2. 获取介质数量
3. 获取存储信息
4. 设备配置（语言）
5. 设备基本信息
6. 预览
7. AI对话图片、音频（pcm）数据步骤
8. 拍照
9. 视频
10. 记录
11. 其他功能（本地ota、重启、断开连接）

## 注意
1. 关于眼镜项目的新接口的使用，请参阅Wiki的第8项
2. 通过调用startPreviewSet、startRecordSet、startRecordVideoSet、devicetakepphoto方法获得的结果只说明设备是否正常收到了命令，WMGlassesVideoAppDelegate方法通过将设备的真实结果发送给APP 
3. 录音、录像、预览、拍照的操作是互斥的，即 当正在进行其它某一项的打开或关闭操作时，在设备没有通知操作结果前，APP端应该禁止用户操作 这4项，防止设备出问题

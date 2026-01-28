#pragma once
#include <stdint.h>

#ifdef __cplusplus
// OTA SDK 专用命名空间，避免与 SJWatchLib 的 SmartLinkCore 冲突
namespace UNIOTACore
{
	/// CRC16 和加密算法类
	/// 用于 OTA 文件校验
	class UNIOTACLFSR
	{
	public:
		UNIOTACLFSR(){};
		~UNIOTACLFSR(){};
	public:
		/// 加密数据
		void Encrypt_Data(uint16_t init_key, uint8_t *l_data, uint32_t length);
		
		/// 计算 CRC8 Maxim 校验值
		uint8_t crc8_maxim(uint8_t *buff, uint16_t length);
		
		/// 计算 CRC16 校验值
		uint16_t get_crc(uint16_t val, uint8_t *buf, uint32_t len);
		
	private:
		uint16_t Loop_Key(uint16_t key);
		uint16_t Encrypt_OneByte(uint8_t* l_data, uint16_t key);
	};
};
#endif

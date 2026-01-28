//
//  UNIOTACLFSR.mm
//  UNIWatchMateDemo - OTA SDK
//
//  重命名自 LSFR.mm
//  专用于 OTA SDK，避免与 SJWatchLib 冲突
//

#include "UNIOTACLFSR.h"

#define  POLY_LFSR16    0xD103
#define  POLY_CRC16     0x1021

// 使用 OTA SDK 专用命名空间
using namespace UNIOTACore;

// 内部辅助函数：计算单字节CRC
static uint16_t get_crc_1byte(uint16_t lastcrc, uint16_t byte_val) {
    uint32_t i;
    for (i = 0; i < 8; i++) {
        if (((byte_val << i) ^ (lastcrc >> 8)) & 0x80) {
            lastcrc <<= 1;
            lastcrc = lastcrc ^ POLY_CRC16;
        }
        else { lastcrc <<= 1; }
    }
    return lastcrc;
}

// UNIOTACLFSR 类方法实现

uint16_t UNIOTACLFSR::Loop_Key(uint16_t key) {
    uint16_t l_temp;
    if (key & 0x8000) {
        l_temp = POLY_LFSR16;
    } else {
        l_temp = 0x0000;
    }

    key = (((key << 1) ^ l_temp) | (key >> 15));
    return key;
}

uint16_t UNIOTACLFSR::Encrypt_OneByte(uint8_t *l_data, uint16_t key) {
    int i;
    uint16_t l_key;
    uint8_t l_encdata = 0;
    for (i = 8; i > 0; i--) {
        l_encdata <<= 1;
        l_encdata |= ((*l_data >> (i - 1)) ^ (key >> 15)) & 0x01;

        key = Loop_Key(key);
    }
    *l_data = l_encdata;
    l_key = key;

    return l_key;
}

void UNIOTACLFSR::Encrypt_Data(uint16_t init_key, uint8_t *l_data, uint32_t length) {
    uint32_t i;
    uint16_t key = init_key;
    for (i = 0; i < length; i++) {
        key = Encrypt_OneByte(&l_data[i], key);
    }
}

uint8_t UNIOTACLFSR::crc8_maxim(uint8_t *buff, uint16_t length) {
    uint8_t i;
    uint8_t crc = 0; // 初始值
    
    while (length--) {
        crc ^= *buff++; // crc ^= *buff; buff++;
        for (i = 0; i < 8; i++) {
            if (crc & 1) 
                crc = (crc >> 1) ^ 0x8C; // 0x8C = reverse 0x31
            else 
                crc >>= 1;
        }
    }
    
    return crc;
}

uint16_t UNIOTACLFSR::get_crc(uint16_t val, uint8_t *buf, uint32_t len) {
    uint32_t i;
    for (i = 0; i < len; i++) { 
        val = get_crc_1byte(val, buf[i]); 
    }
    return val;
}

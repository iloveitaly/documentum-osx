//
// AQDataExtensions.m
//
// Copyright (c) 2005, Lucas Newman
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//	Redistributions of source code must retain the above copyright notice,
//	 this list of conditions and the following disclaimer.
//	Redistributions in binary form must reproduce the above copyright notice,
//	 this list of conditions and the following disclaimer in the documentation and/or
//	 other materials provided with the distribution.
//	Neither the name of Aquatic nor the names of its contributors may be used to 
//	 endorse or promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "MABEncrypt.h"
#include <openssl/aes.h>

// 64 bit compatibility: http://dev.stuconnolly.com/svn/sequelpro/trunk/Source/SPDataAdditions.m

NSData *EncyptData(NSData *data, NSString *password) {
	// Create a random 128-bit initialization vector
	srand((unsigned int)time(NULL));
	NSInteger ivIndex;
	unsigned char iv[16];
	for (ivIndex = 0; ivIndex < 16; ivIndex++)
		iv[ivIndex] = rand() & 0xff;
	
	// Calculate the 16-byte AES block padding
	NSInteger dataLength = [data length];
	NSInteger paddedLength = dataLength + (32 - (dataLength % 16));
	NSInteger totalLength = paddedLength + 16; // Data plus IV
	
	// Allocate enough space for the IV + ciphertext
	unsigned char *encryptedBytes = calloc(1, totalLength);
	// The first block of the ciphertext buffer is the IV
	memcpy(encryptedBytes, iv, 16);
	
	unsigned char *paddedBytes = calloc(1, paddedLength);
	memcpy(paddedBytes, [data bytes], dataLength);
	
	// The last 32-bit chunk is the size of the plaintext, which is encrypted with the plaintext
	NSInteger bigIntDataLength = NSSwapHostIntToBig((unsigned int)dataLength);
	memcpy(paddedBytes + (paddedLength - 4), &bigIntDataLength, 4);
	
	// Create the key from first 128-bits of the 160-bit password hash
	unsigned char passwordDigest[20];
	SHA1((const unsigned char *)[password UTF8String], strlen([password UTF8String]), passwordDigest);
	AES_KEY aesKey;
	AES_set_encrypt_key(passwordDigest, 128, &aesKey);
	
	// AES-128-cbc encrypt the data, filling in the buffer after the IV
	AES_cbc_encrypt(paddedBytes, encryptedBytes + 16, paddedLength, &aesKey, iv, AES_ENCRYPT);
	free(paddedBytes);
	
	return [NSData dataWithBytesNoCopy:encryptedBytes length:totalLength];
}

NSData *DecryptData(NSData *data, NSString *password) {
	// Create the key from the password hash
	unsigned char passwordDigest[20];
	SHA1((const unsigned char *)[password UTF8String], strlen([password UTF8String]), passwordDigest);
	
	// AES-128-cbc decrypt the data
	AES_KEY aesKey;
	AES_set_decrypt_key(passwordDigest, 128, &aesKey);
	
	// Total length = encrypted length + IV
	NSInteger totalLength = [data length];
	NSInteger encryptedLength = totalLength - 16;
	
	// Take the IV from the first 128-bit block
	unsigned char iv[16];
	memcpy(iv, [data bytes], 16);
	
	// Decrypt the data
	unsigned char *decryptedBytes = (unsigned char*)malloc(encryptedLength);
	AES_cbc_encrypt([data bytes] + 16, decryptedBytes, encryptedLength, &aesKey, iv, AES_DECRYPT);
	
	// If decryption was successful, these blocks will be zeroed
	if ( *((UInt32*)decryptedBytes + ((encryptedLength / 4) - 4)) ||
		*((UInt32*)decryptedBytes + ((encryptedLength / 4) - 3)) ||
		*((UInt32*)decryptedBytes + ((encryptedLength / 4) - 2)) )
	{
		return nil;
	}
	
	// Get the size of the data from the last 32-bit chunk
	NSInteger bigIntDataLength = *((UInt32*)decryptedBytes + ((encryptedLength / 4) - 1));
	NSInteger dataLength = NSSwapBigIntToHost((unsigned int)bigIntDataLength);
	
	return [NSData dataWithBytesNoCopy:decryptedBytes length:dataLength];
}

#![no_std]

use aes_gcm::{
    // aead::{Aead, KeyInit},
    aead::{AeadInPlace, KeyInit, Buffer},
    Aes256Gcm, Nonce, Key
};

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    unsafe { core::hint::unreachable_unchecked() }
}

// Implement Buffer trait for a slice wrapper
struct SliceBuffer<'a> {
    data: &'a mut [u8],
    len:  usize,
}

impl<'a> SliceBuffer<'a> {
    fn new(data: &'a mut [u8], len: usize) -> Self {
        Self { data, len }
    }
}

impl<'a> AsRef<[u8]> for SliceBuffer<'a> {
    fn as_ref(&self) -> &[u8] {
        &self.data[.. self.len]
    }
}

impl<'a> AsMut<[u8]> for SliceBuffer<'a> {
    fn as_mut(&mut self) -> &mut [u8] {
        &mut self.data[..self.len]
    }
}

impl<'a> Buffer for SliceBuffer<'a> {
    fn extend_from_slice(&mut self, _other: &[u8]) -> aes_gcm::aead::Result<()> {
        // Not needed for decryption
        Err(aes_gcm:: Error)
    }

    fn truncate(&mut self, len: usize) {
        self.len = len;
    }

    fn len(&self) -> usize {
        self.len
    }

    fn is_empty(&self) -> bool {
        self.len == 0
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn decrypt(data: *const u8, data_len: usize, result: *mut u8) {
    unsafe {
        let data_slice = core::slice::from_raw_parts(data, data_len);
        let result_slice = core::slice::from_raw_parts_mut(result, data_len - 61);

        decrypt_inner(data_slice, result_slice);
    }
}

fn decrypt_inner(data: &[u8], result: &mut [u8]) {
    let keyspace = data[0];
    let mut key = [0u8; 32];
    key.copy_from_slice(&data[1..33]);

    let nonce_bytes = &data[33..45];
    let ciphertext_with_tag = &data[45..]; // ciphertext + 16 byte tag

    loop {
        let mut i: u8 = 0;
        while i < keyspace {
            let shift: u8 = i & 7;
            let byte_index = (i >> 3) as usize;
            key[byte_index] ^= 1u8 << shift;

            if ((key[byte_index] >> shift) & 1) != 0 {
                break;
            }

            i += 1;
        }

        // Copy ciphertext+tag to result buffer
        result[..ciphertext_with_tag.len()].copy_from_slice(ciphertext_with_tag);

        let key_obj = Key::<Aes256Gcm>::from_slice(&key);
        let cipher = Aes256Gcm::new(key_obj);
        let nonce = Nonce::from_slice(nonce_bytes);

        let mut buffer = SliceBuffer::new(result, ciphertext_with_tag.len());

        // Decrypt in-place (tag is at the end of buffer)
        if cipher.decrypt_in_place(nonce, b"", &mut buffer).is_ok() {
            break;
        }
    }
}
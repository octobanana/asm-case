%ifdef
                                    88888888
                                  888888888888
                                 88888888888888
                                8888888888888888
                               888888888888888888
                              888888  8888  888888
                              88888    88    88888
                              888888  8888  888888
                              88888888888888888888
                              88888888888888888888
                             8888888888888888888888
                          8888888888888888888888888888
                        88888888888888888888888888888888
                              88888888888888888888
                            888888888888888888888888
                           888888  8888888888  888888
                           888     8888  8888     888
                                   888    888

                                   OCTOBANANA

Licensed under the MIT License

Copyright (c) 2019 Brett Robinson <https://octobanana.com/>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
%endif

bits 64

section .data

EOF: equ 0
STDIN: equ 0
STDOUT: equ 1
STDERR: equ 2

optval_uppercase: db 1

optstr_lowercase: db '-l'
optstr_lowercase_len: equ $-optstr_lowercase

map_uppercase:
  db '.','.','.','.', '.','.','.','.', '.',9,10,11,     '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db ' ','!','"','#', '$','%','&',"'", '(',')','*','+', ',','-','.','/'
  db '0','1','2','3', '4','5','6','7', '8','9',':',';', '<','=','>','?'

  DB '@','A','B','C', 'D','E','F','G', 'H','I','J','K', 'L','M','N','O'
  DB 'P','Q','R','S', 'T','U','V','W', 'X','Y','Z','[', '\',']','^','_'
  DB '`','A','B','C', 'D','E','F','G', 'H','I','J','K', 'L','M','N','O'
  DB 'P','Q','R','S', 'T','U','V','W', 'X','Y','Z','{', '|','}','~','.'

  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'

  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'

map_lowercase:
  db '.','.','.','.', '.','.','.','.', '.',9,10,11,     '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db ' ','!','"','#', '$','%','&',"'", '(',')','*','+', ',','-','.','/'
  db '0','1','2','3', '4','5','6','7', '8','9',':',';', '<','=','>','?'

  db '@','a','b','c', 'd','e','f','g', 'h','i','j','k', 'l','m','n','o'
  db 'p','q','r','s', 't','u','v','w', 'x','y','z','[', '\',']','^','_'
  db '`','a','b','c', 'd','e','f','g', 'h','i','j','k', 'l','m','n','o'
  db 'p','q','r','s', 't','u','v','w', 'x','y','z','{', '|','}','~','.'

  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'

  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'
  db '.','.','.','.', '.','.','.','.', '.','.','.','.', '.','.','.','.'

section .bss

buf_len: equ 1024
buf: resb buf_len

section .text

global main

extern read, write, strlen

main:
  cmp rdi, 0
  jz input
  mov rbp, [rsi]

opt:
  push rsi
  push rdi

  mov rdi, rbp
  call strlen

  mov rcx, rax
  pop rdi
  pop rsi

.parse:
  cmp rcx, optstr_lowercase_len
  jne .cond
  dec rcx

.loop:
  mov al, byte [optstr_lowercase + rcx]
  cmp al, byte [rbp + rcx]
  jne .cond
  dec rcx
  jnz .loop
  mov al, byte [optstr_lowercase + rcx]
  cmp al, byte [rbp + rcx]
  jne .cond
  mov byte [optval_uppercase], 0

.cond:
  lea rsi, [rsi + 8]
  mov rbp, [rsi]
  dec rdi
  jnz opt

input:
  mov rdi, STDIN
  mov rsi, buf
  mov rdx, buf_len
  call read

  cmp rax, EOF
  jl quit_error
  je quit

  mov r12, rax
  mov rcx, rax
  mov rbp, buf
  dec rbp

  cmp byte [optval_uppercase], 0
  je lowercase

uppercase:
  xor rax, rax
  mov al, byte [rbp + rcx]
  mov al, byte [map_uppercase + rax]
  mov byte [rbp + rcx], al
  dec rcx
  jnz uppercase
  jmp output

lowercase:
  xor rax, rax
  mov al, byte [rbp + rcx]
  mov al, byte [map_lowercase + rax]
  mov byte [rbp + rcx], al
  dec rcx
  jnz lowercase

output:
  mov rdx, r12
  mov rsi, buf
  mov rdi, STDOUT
  call write

  cmp r12, rax
  jne quit_error
  jmp input

quit:
  xor rax, rax
  ret

quit_error:
  mov rax, 1
  ret

.section .data
    file_path:
        .asciz "C:/monRepertoire/monFichier.txt"
    md5_padding:
        .byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    md5_constants:
        .long 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

.section .text
.globl get_md5_hash
.type get_md5_hash, @function

get_md5_hash:
    # Prologue
    push %rbp
    mov %rsp, %rbp

    # Ouvre le fichier en mode binaire
    mov $0, %rax        # sys_open
    mov $file_path, %rdi
    mov $0, %rsi        # O_RDONLY
    mov $0, %rdx
    syscall
    cmp $0, %rax
    jl error_open_file
    mov %rax, %r12      # Sauvegarder le descripteur de fichier

    # Initialise l'objet MD5
    mov $128, %rdi      # taille de l'objet MD5
    mov $1, %rax        # sys_malloc
    syscall
    mov %rax, %r13      # Sauvegarder l'adresse de l'objet MD5
    mov $0x67452301, (%r13)    # a = 0x67452301
    mov $0xefcdab89, 4(%r13)   # b = 0xefcdab89
    mov $0x98badcfe, 8(%r13)   # c = 0x98badcfe
    mov $0x10325476, 12(%r13)  # d = 0x10325476

    # Lit le fichier par blocs et met à jour le hash
    mov %r12, %rdi      # Descripteur de fichier
    mov $64, %rdx       # Taille du bloc
    mov %r13, %rsi      # Adresse de l'objet MD5
read_loop:
    mov $0, %rax        # sys_read
    syscall
    cmp $0, %rax
    jz end_read_loop
    mov %rax, %rdx      # Taille des données lues
    mov %r13, %rdi      # Adresse de l'objet MD5
    call md5_update     # Mettre à jour le hash
    jmp read_loop
end_read_loop:

    # Ajoute le padding et la taille du fichier
    mov %r13, %rdi      # Adresse de l'objet MD5
    call md5_finalize   # Finaliser le hash

    # Ferme le fichier
    mov %r12, %rdi      # Descripteur de fichier
    mov $3, %rax        # sys_close
    syscall

    # Retourne le hash final
    mov %r13, %rdi      # Adresse de l'objet MD5
    call md5_digest
    mov %rax, %rdi      # Retourner le hash

    # Épilogue
    mov %rbp, %rsp
    pop %rbp
    ret

# Fonctions MD5
md5_update:
    # Met à jour l'objet MD5 avec les nouvelles données
    # ...
    # (code de la fonction md5_update inchangé)
    # ...
    ret

md5_finalize:
    # Finalise le hash MD5 en ajoutant le padding et la taille du fichier
    push %rbp
    mov %rsp, %rbp

    # Sauvegarde les registres
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi

    # Récupère la taille du fichier
    mov %r12, %rdi      # Descripteur de fichier
    mov $8, %rax        # sys_lseek
    xor %rsi, %rsi      # SEEK_SET
    xor %rdx, %rdx
    syscall
    mov %rax, 16(%rsi)  # Stocke la taille du fichier

    # Ajoute le padding
    mov $md5_padding, %rsi
    mov $64, %rdx
    call md5_update

    # Restaure les registres
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rbx

    mov %rbp, %rsp
    pop %rbp
    ret

md5_digest:
    # Retourne le hash MD5 final
    push %rbp
    mov %rsp, %rbp

    # Sauvegarde les registres
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi

    # Copie le hash dans un buffer
    mov (%rdi), %eax    # a
    mov 4(%rdi), %ebx   # b
    mov 8(%rdi), %ecx   # c
    mov 12(%rdi), %edx  # d
    bswap %eax
    bswap %ebx
    bswap %ecx
    bswap %edx
    mov %eax, (%rdi)
    mov %ebx, 4(%rdi)
    mov %ecx, 8(%rdi)
    mov %edx, 12(%rdi)

    # Restaure les registres
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rbx

    mov %rbp, %rsp
    pop %rbp
    mov %rdi, %rax      # Retourner l'adresse du hash
    ret

error_open_file:
    # Gérer l'erreur d'ouverture du fichier
    # Ajoutez ici le code de gestion de l'erreur
    ret

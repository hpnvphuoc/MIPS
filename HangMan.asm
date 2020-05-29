# MIPS program that imitates Hang Man game.
#   by 18120210_18120223_18120226_18120254_18120264

.data
	title: .asciiz "=~-=-=-=-=-=| Hang~Man |=-=-=-=-=-~="
	nhapten: .asciiz "\nNhap ten: "
	player.info: .asciiz "\nTen nguoi choi - Tong so diem - So luot chien thang\n"
	end.opt: .asciiz "\n1. Tiep tuc tro choi\n2. Thoat\nLua chon cua ban: "
	MissTurn: .asciiz "\nSo luot da mat: "
	ques: .asciiz "\nNhap chuoi hay ky tu ban doan: "
	tb1: .asciiz "\nGame Over!\n"
	tb2: .asciiz "\nYou Win!\n"
	tt.tb:  .asciiz "\n-------------"
	tt.tb1: .asciiz "\n|/       |"
	tt.tb2: .asciiz "\n|        O"
	tt.tb3: .asciiz "\n|        |"
	tt.tb4: .asciiz "\n|       /|"
	tt.tb5: .asciiz "\n|       /|\\"
	tt.tb6: .asciiz "\n|       /"
	tt.tb7: .asciiz "\n|       / \\"
	tt.tb8: .asciiz "\n|"
	
	fout: .asciiz "nguoichoi.txt"      # filename for output
	
	SeC: .byte '*'
	Line: .byte '-'
	
	lenAns: .word 0	# Do dai chuoi nguoi choi nhap
	lenSeWo: .word 0	# Do dai chuoi de thi
	Miss: .word 0		# So luot doan sai
	Diem: .word 0		# Diem nguoi choi
	WinRound: .word 0	# So luot chien thang
	
	SeWo: .space 20	# Bien chuoi dap an (load tu file)
	Ans: .space 20	# Bien chuoi va ky tu nguoi choi nhap
	Dis: .space 20	# Bien hien thi de thi (ky tu an)	
	Diem_str: .space 20		# Diem nguoi choi (duoi dang string)
	WinRound_str: .space 20	# So luot chien thang (duoi dang string)
	player.name: .space 20	# Ten nguoi choi
	player.inf: .space 63	# player.name-Diem-WinRound*

	
.text
	.globl main	
	
########################### main #################################	
main:	
	#---------new player info---------
Replay:
	# nhap ten nguoi choi
	li $v0,4
	la $a0,nhapten
	syscall 
	
	li $v0, 8		
	la $a0, player.name
	li $a1, 20
	syscall
	
	# khoi tao
	li $a0,0
	la $a1,Diem
	sw $a0,($a1)		# Diem = 0
	
	la $a1,WinRound
	sw $a0,($a1)		# WinRound = 0
	
	#--------create new round---------
NewRound:	
	li $s0, 0		
	sw $s0, Miss	
	
	#---------doc file de thi---------
	
	li $v0, 8		# nhap de thi
	la $a0, SeWo
	li $a1, 20
	syscall
	
	la $a0, SeWo		
	jal _Length
	sw $v1, lenSeWo	# so ky tu de thi
			
	la $a0, Dis
	lw $a1, lenSeWo
	jal _ConDis		# khoi tao chuoi an cua de thi

	#------------game loop------------	
GameLoop: 
	# in tieu de
	li $v0, 4
	la $a0, title
	syscall
	# in tb so luot da mat
	li $v0, 4
	la $a0, MissTurn
	syscall
	# in so luot mat
	li $v0, 1
	lw $a0, Miss
	syscall
	# in ky tu xuong dong
	li $v0, 11
	li $a0, '\n'
	syscall
	
	# in chuoi an
	li $v0, 4
	la $a0, Dis
	syscall
	
	# in gia treo co
	lw $a0, Miss
	jal _XuatTrangThai

	# kiem tra dieu kien thua
	lw $s0, Miss
	bge $s0, 7, GameOver
	
	# kiem tra dieu kien thang
	la $a0, Dis
	lw $a1, lenSeWo
	jal _CountHL
	move $s0, $v1		# so ky tu an
	
	beqz $s0, GameWin	# so ky tu an = 0 -> win
	
	# in cau hoi
	li $v0, 4
	la $a0, ques
	syscall
	
	# nhap cau tra loi
	li $v0, 8
	la $a0, Ans
	li $a1, 20
	syscall
	
	# tinh so ky tu trong cau tra loi
	la $a0, Ans
	jal _Length
	sw $v1, lenAns
	
	lw $t1, lenAns
	bgt $t1, 1, String		# so ky tu > 1 -> nguoi choi nhap chuoi
	
Char:	
	# xu ly nhap mot ky tu
	la $a0, SeWo			# dap an
	lw $a1, lenSeWo		# do dai chuoi dap an
	la $a2, Dis			# de thi duoi dang *
	lb $a3, Ans			# dap an nguoi choi 
	jal _AnsDis			# tra ve so_ky_tu_doan_dung	
	# doan dung			
	bnez $v1, Char.continue	# tiep tuc choi 
	# doan sai
	lw $s0, Miss			
	add $s0, $s0, 1		# so_lan_doan_sai ++
	sw $s0, Miss			
Char.continue:
	j GameLoop			
	
String:
	# xu ly nhap chuoi 
	la $a0, SeWo
	lw $a1, lenSeWo
	la $a2, Ans
	lw $a3, lenAns
	jal _AnsStr			
	beqz $v1, GameOver		# v1 = 0 thi thua
	b GameWin			

GameOver:
	# xuat tb thua
	li $v0, 4
	la $a0, tb1
	syscall
	# xuat thong tin nguoi choi
	li $v0,4
	la $a0,player.info
	syscall 
	li $v0,4
	la $a0,player.name
	syscall 
	li $v0,11
	la $a0,'-'
	syscall
	li $v0,1
	la $a0,Diem
	lw $a0,($a0)
	syscall 
	li $v0,11
	la $a0,'-'
	syscall
	li $v0,1
	la $a0,WinRound
	lw $a0,($a0)
	syscall 
	
	#-------ghi file nguoi choi-------

	# Mo file ghi
	li $v0,13       
  	la $a0,fout     
  	li $a1,9		# 9: write-only with create and append
 	li $a2,0      	# mode is ignored
 	syscall            	# file descriptor -> $v0
  	move $s6,$v0      	# luu file descriptor 

	# chuyen Diem thanh string
	la $a0,Diem
	lw $a0,($a0)
	la $a1,Diem_str
	jal _IntToStr
	# chuyen WinRound thanh string
	la $a0,WinRound
	lw $a0,($a0)
	la $a1,WinRound_str
	jal _IntToStr
	# tao chuoi player.name-Diem-WinRound*
	la $a0,player.name
	la $a1,Diem_str
	la $a2,WinRound_str
	la $a3,player.inf
	jal _PlayerInfoStr
	
	# tinh do dai chuoi de ghi file ($a2)
	la $a0,player.inf
	jal _LengthBuffer
	addi $v0,$v0,1	# them ki tu ket thuc?
	move $a2,$v0
  	
  	# Ghi file
  	li $v0,15       
  	move $a0,$s6      
  	la $a1,player.inf   
  	syscall      
  	
	# Dong file 
  	li $v0,16       
  	move $a0,$s6      
  	syscall  
	
	#-------lua chon nguoi choi-------
	
	# xuat tb chon
	li $v0,4
	la $a0,end.opt
	syscall
	# nhap lua chon
	li $v0,5
	syscall
	
	beq $v0,1,Replay	# tiep tuc choi
	bne $v0,1,end		# thoat
	
GameWin:
	#reset Dis
	la $a0, Dis
	lw $a1, lenSeWo
	jal _spcDis
	# xuat tb thang
	li $v0, 4
	la $a0, tb2
	syscall	
	# cong diem
	la $a0,lenSeWo
	lw $a1,($a0)
	la $a0,Diem
	lw $a2,($a0)
	add $a2,$a2,$a1
	sw $a2,Diem	
	# tang so luot chien thang
	la $a0,WinRound
	lw $a0,($a0)
	addi $a0,$a0,1
	sw $a0,WinRound
	
	j NewRound
	
	#------------end game-------------
end:	
	li $v0, 10
	syscall
	
####################### end of main ##############################


#=============== Thu tuc _Length ====================
# Tinh do dai chuoi (ket thuc bang '\n')
# Truyen vao: a0 = $str
# Tra ve: v1 = do dai str
_Length:
	add $sp, $sp,-20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	
	move $s0, $a0
	
	#khoi tao 
	li $t0, 0		# i = 0
	
_Length.loop:
	add $t2, $s0, $t0 	# $str + i
	lb $t1, ($t2)		# lay gia tri $str
	beq $t1, '\n', _Length.end	
	add $t0, $t0, 1	# i ++
	j _Length.loop
_Length.end:
	add $v1, $t0, 0	# return i
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	
	addi $sp, $sp, 20
	jr $ra
#=============== end of _Length =====================


#=============== Thu tuc _LengthBuffer ====================
# Tinh do dai chuoi (ket thuc = $0)
# Truyen vao: a0 = $str
# Tra ve: v0 = do dai str
_LengthBuffer:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	
	move $s0,$a0
	
	li $t0,0		# i = 0
_LengthBuffer.loop:
	lb $t1,($s0)	
	beq $t1,$0,_LengthBuffer.end
	add $t0,$t0,1		# i++	
	add $s0,$s0,1	
	j _LengthBuffer.loop
_LengthBuffer.end:
	add $t0,$t0,-1	# i -- 
	move $v0,$t0		# return i
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	addi $sp, $sp, 16
	jr $ra
#=============== end of _LengthBuffer =====================


#=============== Thu tuc _ConDis ====================
# Ham khoi tao an cau (luu de thi duoi dang *)	
# Truyen vao: a0: Dis(hien thi ky tu an); a1: lenSeWo(do dai chuoi de thi)
# Tra ve: khong co
_ConDis:
	add $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	# khoi tao
	li $t0, 0		# i = 0
	lb $t2, SeC		# '*'
_ConDis.loop:
	bge $t0, $s1, _ConDis.end	# i >= lenSeWo thi end
	add $t1, $t0, $s0		# t1 = $Dis + i
	sb $t2, ($t1)			# [t1] = '*' 
	add $t0, $t0, 1		# i ++
	j _ConDis.loop
_ConDis.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	
	add $sp, $sp, 24
	jr $ra
#=============== end of _ConDis =====================	
	

#================ Thu tuc _AnsDis ===================
# Xu ly ky tu nguoi choi nhap vao
# Truyen vao: a0: SeWo(dap an); a1: lenSeWo(do dai de thi); a2: Dis(de thi duoi dang *); a3: Ans(dap an nguoi choi) 
# Tra ve: v1 = so ky tu doan dung
_AnsDis:
	add $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)
	sw $t3, 32($sp)
	sw $t4, 36($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# khoi tao
	li $t0, 0	# i = 0
	li $t4, 0	# so_ky_tu_doan_dung = 0
_AnsDis.loop:
	bge $t0, $s1, _AnsDis.end	# i >= lenSeWo thi end
	add $t1, $s0, $t0		# t1 = $SeWo + i
	lb $t3, ($t1)			# t3 = [t1]
	add $t2, $s2, $t0		# t2 = $Dis + i
	bne $s3, $t3, _AnsDis.loop.continue	# $Ans != t3 thi lap (!= dap_an[i])
	sb $s3, ($t2)			# t2 = [$Ans] -> hien thi dap an neu nguoi choi doan dung
	add $t4, $t4, 1		# so_ky_tu_doan_dung ++
 _AnsDis.loop.continue:
	add $t0, $t0, 1		# i ++
	j _AnsDis.loop
	
_AnsDis.end:	
	move $v1, $t4			# return j
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	lw $t3, 32($sp)
	lw $t4, 36($sp)
	
	addi $sp, $sp, 40
	jr $ra
#================ end of _AnsDis ====================


#================ Thu tuc _AnsStr ===================
# So sanh chuoi nguoi choi nhap voi ket qua
# Truyen vao: a0: SeWo(dap an); a1: lenSeWo(do dai de thi); a2: Ans(dap an nguoi choi); a3: lenAns(do dai dap an nguoi choi) 
# Tra ve: v1 = 0 thi thua
_AnsStr:
	add $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)
	sw $t3, 32($sp)
	sw $t4, 36($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# lenSeWo = lenAns
	beq $s1, $s3, _AnsStr.le	# check dung sai
	
	# khoi tao
	li $v1, 0			# win: false
	
	# doan sai
	j _AnsStr.end			
_AnsStr.le:
	li $t0, 0			# i = 0
_AnsStr.loop:
	li $v1, 1			# win: true
	bge $t0, $s1, _AnsStr.end	# i >= lenSeWo thi thoat
	add $t1, $s0, $t0		# t1 = $SeWo + i
	lb $t3, ($t1)			# t3 = [t1]
	add $t2, $s2, $t0		# t2 = $Ans + i
	lb $t4, ($t2)			# t4 = [t2]
	bne $t3, $t4, _AnsStr.nec	# t3 != t4 -> thua
	add $t0, $t0, 1		# i ++
	j _AnsStr.loop
_AnsStr.nec:
	li $v1, 0			# win: false
_AnsStr.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	lw $t3, 32($sp)
	lw $t4, 36($sp)	
	addi $sp, $sp, 40
	jr $ra
#================ end of _AnsStr ====================

		
#============= Thu Tuc _CountHL =====================
# Dem con bao nhieu ky tu an
# Truyen vao: a0: Dis(bien hien thi ky tu an); a1: lenSeWo(do dai chuoi de thi)
# Tra ve: v1 = so ky tu chua doan 
_CountHL:
	add $sp, $sp, -32
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)	
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	# khoi tao
	li $t0, 0		# i = 0
	li $t4, 0		# ky_tu_an = 0
	lb $t2, SeC		# '*'
_CountHL.loop:
	bge $t0, $s1, _CountHL.end		# i >= lenSeWo thi end
	add $t1, $s0, $t0			# t1 = $Dis +  i
	lb $t3, ($t1)				# t3 = [t1]
	bne $t2, $t3, _CountHL.loop.continue	# t3 != '*' thi tang dem
	add $t4, $t4, 1			# ky_tu_an ++
_CountHL.loop.continue:
	add $t0, $t0, 1	# i ++		
	j _CountHL.loop
_CountHL.end: 
	move $v1, $t4		# return ky_tu_an
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)	
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	
	addi $sp, $sp, 32
	jr $ra
#================ end of _CountHL ===================

	
#================ Thu tuc _spcDis ===================
# Lam trong chuoi Dis
# Truyen vao: $a0: Dis, $a1: lenSeWo
# Tra ve: khong
_spcDis:
	add $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	li $t0, 0
	li $t2, 0
_spcDis.loop:
	bge $t0, $s1, _spcDis.end
	add $t1, $s0, $t0
	sb $t2, ($t1)
	add $t0, $t0, 1
	b _spcDis.loop
_spcDis.end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	
	add $sp, $sp, 24
	jr $ra
#================ end of _spcDis ====================

						
#============== Thu tuc _IntToStr ===================
# Chuyen so nguyen thanh chuoi
# Truyen vao: a0 = int, a1 = $string 
# Tra ve: khong
_IntToStr:
 	addi $sp,$sp,-32
 	sw $ra,($sp)
 	sw $s0,4($sp)		
 	sw $s1,8($sp)
 	sw $t0,12($sp)
 	sw $t1,16($sp)
 	sw $t2,20($sp)
 	sw $t3,24($sp)
 	sw $t4,28($sp)
 	
 	move $s0,$a0		# n
 	move $s1,$a1		# $n_str
 	
 	# khoi tao
 	li $t0,1		# i = 1: so chu so
 	li $t1,1		# j = 1
 	li $t2,10		# 10
DemSoChuSo.Loop:
 	div $s0,$t1		# n / j
 	mflo $t3		# thuong
 	mfhi $t4		# so du
 	blt $t3,10,LayGiaTri.Loop		# thuong < 10 -> end	
 	j DemSoChuSo.TangDem
DemSoChuSo.TangDem:
	add $t0,$t0,1		# i ++
	mult $t1,$t2		# j*10
 	mflo $t1
	j DemSoChuSo.Loop
LayGiaTri.Loop: 				
 	div $s0,$t1		# n / j
 	mflo $t3		# thuong
 	mfhi $s0		# so du
 	
 	# convert thuong thanh ascii
 	addi $t3,$t3,48
 	# luu thuong vao n_str
 	sb $t3,($s1)
 	
 	# neu j = 1 thi thoat
 	beq $t1,1,LayGiaTri.Thoat
 	
 	addi $s1,$s1,1	# tang dia chi
 	
 	div $t1,$t2		# j /= 10
 	mflo $t1
 
 	j LayGiaTri.Loop
 	
LayGiaTri.Thoat:	
 	lw $ra,($sp)
 	lw $s0,4($sp)		
 	lw $s1,8($sp)
 	lw $t0,12($sp)
 	lw $t1,16($sp)
 	lw $t2,20($sp)
 	lw $t3,24($sp)
 	lw $t4,28($sp)
	addi $sp,$sp,32
	jr $ra
#================ end of _IntToStr ==================						


#============ Thu tuc _PlayerInfoStr ================
# Tao chuoi thong tin nguoi choi ($player.inf)
# Truyen vao: a0 = $player.name, a1 = $Diem, a2 = $WinRound, a3 = $player.inf 
# Tra ve: khong
_PlayerInfoStr:
 	addi $sp,$sp,-36
 	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
 	sw $t0,20($sp)
 	sw $t1,24($sp)
 	sw $t2,28($sp)
 	sw $t3,32($sp)
 	
 	move $s0,$a0		# $player.name
 	move $s1,$a1		# $Diem
 	move $s2,$a2		# $WinRound
 	move $s3,$a3		# $player.inf
 	
 	# khoi tao
	li $t0,0		# i = 0
	
	la $t2,SeC
	lb $t2,($t2)		# '*'
	la $t3,Line
	lb $t3,($t3)		# '-'
	
	# ghi ten nguoi choi		
_PlayerInfoStr.PlayerName:	
 	lb $t1,($s0)
 	beq $t1,$0,_PlayerInfoStr.Line1
 	sb $t1,($s3)
 	addi $s0,$s0,1
 	addi $s3,$s3,1
 	j _PlayerInfoStr.PlayerName
 	
 	# ghi so diem
_PlayerInfoStr.Diem:
 	lb $t1,($s1)
 	beq $t1,$0,_PlayerInfoStr.Line2
	sb $t1,($s3)
	addi $s1,$s1,1
	addi $s3,$s3,1
	j _PlayerInfoStr.Diem
	
	# ghi luot thang
_PlayerInfoStr.WinRound:
	lb $t1,($s2)
 	beq $t1,$0,_PlayerInfoStr.Exit
	sb $t1,($s3)
	addi $s2,$s2,1
	addi $s3,$s3,1
	j _PlayerInfoStr.WinRound

	# ghi '-'
_PlayerInfoStr.Line1:	
	sb $t3,($s3)
	addi $s3,$s3,1
	j _PlayerInfoStr.Diem
_PlayerInfoStr.Line2:	
	sb $t3,($s3)
	addi $s3,$s3,1
	j _PlayerInfoStr.WinRound
		
	# ghi '*'														
_PlayerInfoStr.Exit: 	
 	sb $t2,($s3)
 	
 	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
 	lw $t0,20($sp)
 	lw $t1,24($sp)
 	lw $t2,28($sp)
 	lw $t3,32($sp)
	addi $sp,$sp,36
	jr $ra
#============== end of _PlayerInfoStr ===============

			
#============= Thu tuc _XuatTrangThai ===============
# Xuat ra trang thai tuong ung voi so luot doan sai
# Truyen vao: a0 = so luot doan sai
# Tra ve: khong
_XuatTrangThai:
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	#Load gia tri
	move $s0, $a0

	#Khoi bien i = 1 de so sanh truong hop false = 1
	li $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False1
	#tang i len 2 de so sanh truong hop false = 2
	li $t0, 2
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False2
	#tang i len 3 de so sanh truong hop false = 3
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False3
	#tang i len 4 de so sanh truong hop false = 4
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False4
	#tang i len 5 de so sanh truong hop false = 5
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False5
	#tang i len 6 de so sanh truong hop false = 6
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False6
	#tang i len  de so sanh truong hop false = 7
	addi $t0, $t0, 1
	seq $t1, $s0, $t0
	beq $t1, 1, _XuatTrangThai.False7
	
	# false = 0
	jal _XuatTrangThai.End1
	
_XuatTrangThai.False1:
	#Sai 1 lan
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall
 	
	jal _XuatTrangThai.End
_XuatTrangThai.False2:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False3:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb3
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False4:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb4
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False5:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.False6:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	li $v0, 4
	la $a0, tt.tb6
	syscall
	
	jal _XuatTrangThai.End
_XuatTrangThai.False7:
	li $v0, 4
	la $a0, tt.tb
	syscall
	
	li $v0, 4
	la $a0, tt.tb1
	syscall

	li $v0, 4
	la $a0, tt.tb2
	syscall

	li $v0, 4
	la $a0, tt.tb5
	syscall

	li $v0, 4
	la $a0, tt.tb7
	syscall

	jal _XuatTrangThai.End
_XuatTrangThai.End:
	li $v0, 4
	la $a0, tt.tb8
	syscall
	li $v0, 4
	syscall
	li $v0, 4
	syscall
	li $v0, 4
	syscall
_XuatTrangThai.End1:
       lw $ra, ($sp)
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	addi $sp, $sp, 16
	jr $ra
#================ end of _XuatTrangThai ===================
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

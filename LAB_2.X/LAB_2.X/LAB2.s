/* Archivo: Main.S
   Dispositivo: PIC16F887
   Autor: LUZ GALINDO
   Compilador: pic-as (v2.30), MPLABX V5.40
     
   Programa: Contador en el puerto A
   Hardware: LEDs en el puerto A
     
   Creado: 03/02/2021
   Última modificación: 03/02/2023 
 */
PROCESSOR 16F887
#include <xc.inc>

;configuration word 1
 CONFIG FOSC = INTRC_NOCLKOUT // Oscillador interno salidas
 CONFIG WDTE = OFF // Watchdog Timer desabilidato
 CONFIG PWRTE = OFF // PWRT desabilitado
 CONFIG MCLRE = OFF // El ping de MCLR se utiliza como I/o
 CONFIG CP = OFF // Sin proteccion de codigo
 CONFIG CPD = OFF  // Sin proteccion de datos
 CONFIG BOREN = OFF // Sin reinicio cuando el voltaje baje
 CONFIG IESO = OFF // Reinicio sin cambio de reloj
 CONFIG FCMEN = OFF // Cambio de reloj externo a interno por fallo
 CONFIG LVP = OFF // Programacion permitida para bajo voltaje
 
 ;configuración2
 CONFIG WRT=OFF // Proteccion de autoescritura desactivada
 CONFIG BOR4V=BOR40V // Reinicio abajo de 4V
 
 PSECT udata_bank0 ;common memory
    cont: DS 2; 2 byte

PSECT resVect, Class=CODE, abs, delta=2
;-------------Vector reset------------------------------------
ORG 00h ;    posicion reset
resetVec:
    PAGESEL main
    goto main
    
PSECT code, delta=2, abs
 ORG 100h ; posición codigo

;-------------Configuración-------------------------------------
 
 main:
    call config_io //LLamar la subrutina de config_io
    call config_reloj //LLamar la subrutina de config_reloj
    bcf STATUS, 5 //regresar al banco 0
    bcf STATUS, 6 
;-----------loop principal---------------------------------------
loop:
    call cont1 //Llamar a la subrutina del contador 1
    call cont2 //Llamar a la subrutina del contador 2
    call sum_cont //Llamar a la subrutina de suma
    call loop //Mantener el loop activado
    
config_io:
    //entradas digitales
    bsf STATUS, 5 //cambiar al banco 3
    bsf STATUS, 6 //cambiar al banco 3
    clrf ANSEL //establecer entradas y salidas digitales
    clrf ANSELH //establecer entradas y salidas digitales
    
    //establecer como salidas o entradas
    bsf	    STATUS, 5 //cambiar al banco 1
    bcf	    STATUS, 6 //cambiar al banco 1
    
    bsf	    TRISA, 0  //establecer RA0 como entrada
    bsf	    TRISA, 1  //establecer RA1 como entrada
    bsf	    TRISA, 2  //establecer RA2 como entrada
    bsf	    TRISA, 3  //establecer RA3 como entrada
    bsf	    TRISA, 4  //establecer RA4 como entrada
    //Establecer puerto B,C y D como salidas
    clrf    TRISB
    clrf    TRISC
    clrf    TRISD
    
    //apagar y limpiar las entradas    
    bcf	    STATUS, 5 //banco 1
    bcf	    STATUS, 6 //banco 1
    
    //Limpiar las entradas de los PORTA-D
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    
    return
 
config_reloj:
    banksel OSCCON 
    // oscilador en 1Mhz
    
    bsf	    IRCF2 //establecido a 0
    bcf	    IRCF1 //establecido a 1
    bcf	    IRCF0 //establecido a 1
    bsf	    SCS //oscilador interno
    
    return
    
cont1: 
    btfsc PORTA, 0 //Salta a la siguiente instrucción sino esta presionado
    call b1 //Llama a la subrutina
    
    btfsc PORTA, 1 //Salta a la siguiente instrucción sino esta presionado
    call b2 //Llama a la subrutina
    
    return 
 
cont2:
    btfsc PORTA, 2 //Salta a la siguiente instrucción sino esta presionado
    call b3 //Llama a la subrutina
    
    btfsc PORTA, 3 //Salta a la siguiente instrucción sino esta presionado
    call b4 //Llama a la subrutina
    
    return 

sum_cont:
    btfsc PORTA, 4 //Salta a la siguiente instrucción sino esta presionado
    call b5 //Llama a la subrutina
    
    return
    
b1:
    call delay //llamar un delay
    btfsc PORTA, 0 //Obviar la siguiente linea al soltar
    goto $-1
    incf PORTB //incrementar
    movlw 15 //mover la literal 15 a w
    andwf PORTB, 1  //comparar el registro w con f  y guardar en f
    
    return
    
b2:
    call delay //llamar un delay
    btfsc PORTA, 1
    goto $-1
    decf PORTB
    movlw 15
    andwf PORTB, 1
    
    return
b3:
    call delay //llamar un delay
    btfsc PORTA, 2
    goto $-1
    incf PORTC
    movlw 15
    andwf PORTC, 1
    
    return
    
b4:
    call delay //llamar un delay
    btfsc PORTA, 3
    goto $-1
    decf PORTC
    movlw 15
    andwf PORTC, 1
    
    return

b5:
    call delay //llamar un delay
    btfsc PORTA, 4
    goto $-1
    movf PORTB, 0
    addwf PORTC, 0
    movwf PORTD
    
delay:
    movlw 150
    movwf cont
    decfsz cont, 1
    goto $-1
    return
    
END
 
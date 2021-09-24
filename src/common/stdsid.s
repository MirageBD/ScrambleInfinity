; voice control register
; Bit #0: 0 = Voice off, Release cycle; 1 = Voice on, Attack-Decay-Sustain cycle.
; Bit #1: 1 = Synchronization enabled.
; Bit #2: 1 = Ring modulation enabled.
; Bit #3: 1 = Disable voice, reset noise generator.
; Bit #4: 1 = Triangle waveform enabled.
; Bit #5: 1 = Saw waveform enabled.
; Bit #6: 1 = Rectangle waveform enabled.
; Bit #7: 1 = Noise enabled.

; $D400					Voice #1 frequency.
; $D401					""
; $D402					Voice #1 pulse width.
; $D403					""
; $D404					Voice #1 control register
; $D405					Voice #1 Attack and Decay length.
; $D406					Voice #1 Sustain volume and Release length.

; $D407					Voice #2 frequency.
; $D408					""
; $D409					Voice #2 pulse width.
; $D40A					""
; $D40B					Voice #2 control register.
; $D40C					Voice #2 Attack and Decay length.
; $D40D					Voice #2 Sustain volume and Release length.

; $D40E					Voice #3 frequency.
; $D40F					""
; $D410					Voice #3 pulse width.
; $D411					""
; $D412					Voice #3 control register.
; $D413					Voice #3 Attack and Decay length.
; $D414					Voice #3 Sustain volume and Release length.

; $D415					Filter cut off frequency (bits #0-#2).
; $D416					Filter cut off frequency (bits #3-#10).
; $D417					Filter control.

; $D418					Volume and filter modes.
;Bits #0-#3: Volume.
;Bit #4: 1 = Low pass filter enabled.
;Bit #5: 1 = Band pass filter enabled.
;Bit #6: 1 = High pass filter enabled.
;Bit #7: 1 = Voice #3 disabled.

; -----------------------------------------------------------------------------------------------

.define sidstart			$d400

.define sidvoice1			sidstart+0*7+0
.define sidvoice2			sidstart+1*7+0
.define sidvoice3			sidstart+2*7+0
.define sidfilter			sidstart+3*7+0
.define sidvolumefilter		sidstart+3*7+3

.define freqlo				0
.define freqhi				1
.define pulswlo				2
.define pulswhi				3
.define ctrl				4
.define attkd				5
.define susvr				6

.define fcutoff1			0
.define fcutoff2			1
.define fctrl				2

.define cvoiceoff			0
.define cvoiceon			1
.define csyncon				2
.define cringon				4
.define cdisable			8
.define ctriangle			16
.define csaw				32
.define crectangle			64
.define cnoise				128

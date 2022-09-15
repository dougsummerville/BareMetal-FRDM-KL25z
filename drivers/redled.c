/*Example driver for red LED on the RGBLED */
/* Douglas Summerville, Binghamton University */
#include <redled.h>
#include <MKL25Z4.h>

#define RED_LED_LOC 18

void configure_red_led()
{
	SIM->SCGC5 |= SIM_SCGC5_PORTB_MASK;
	PORTB->PCR[RED_LED_LOC] =
	   (PORTB->PCR[RED_LED_LOC] & ~(PORT_PCR_MUX_MASK | PORT_PCR_PE_MASK)) 
	   | PORT_PCR_IRQC_MASK | PORT_PCR_MUX(1);
	PTB->PDDR |= (1<<RED_LED_LOC);
	turn_off_red_led();
}
void turn_on_red_led()
{
	PTB->PCOR |= (1<<RED_LED_LOC);
}
void turn_off_red_led()
{
	PTB->PSOR |= (1<<RED_LED_LOC);
}

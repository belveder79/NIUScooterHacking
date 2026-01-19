import ULP
ULP.wake_period(0,20000)
var c = bytes().fromb64("dWxwAAwAzAAAABgAgwOAcg8AANA8AIBwEAAJggkBuC4wAMBwKAAAgAkB+C8PASByMADAcBAAQHIzA4ByDwAA0DMAAHAfAEByVABAgFMDgHJCA4ByDwAA0AsAAGgAAACwQwOAcg4AANAKAABycABAgBoAIHIOAABoAAAAsFMDgHJCA4ByDwAA0AsAAGgzA4ByDgAA0BoAAHIaAEByDgAAaGMDgHIOAADQGgAAcg4AAGhzA4ByDwAA0C8AIHC4AECAAAAAsDAAzCkQAEByuABAgAEAAJAAAACw")
ULP.load(c)
c = nil
var gpio = 14 # change me
var rtc_io_num = ULP.gpio_init(gpio,0) # GPIO to input 
ULP.set_mem(55,2) #edge_count_to_wake_up, debouncing does not seem to be perfect
ULP.set_mem(56,rtc_io_num) #rtc_gpio_number
ULP.run()
ULP.sleep()
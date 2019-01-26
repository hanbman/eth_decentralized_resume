# Avoiding Common Attacks

#### 1. Circuit Breaker / Emergency Stop Pattern
A emergency_stop value is default set to false. There is a modifier for every function in the contract that only lets the function run if the emergency_stop is false. Only the Owner has the ability to change the state of the emergency stop, but the Owner can set it to true and stop all contract functions until the Owner sets the stop back to false.
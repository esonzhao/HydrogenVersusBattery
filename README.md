# Read me
This beginner friendly model serves as a guide on how to simulate renewable energy components in matlab script. It is **NOT** a how-to on code architecture. Its current setup (functional programming) may be too slow if we were to scale the project, so pay closer attention on how governing equations are modelled. Code in the future will be more optimised and readable, I promise.

This model aims to replicate Ferrario et al. 2020's paper, found here: https://www.mdpi.com/2079-9292/9/4/698. 

Two reasons why I'm publishing this code:
1. The authors have not published their source code, so there's no way of verifying or benchmarking their findings.
2. There certainly isn't a lot of information on how to model energy systems in script. Many authors won't share their source code. So, with the limited information I could scrounge, I spent a gruelling few months learning from scratch. After months hitting my head against the wall, here is something I've put together, in hopes of benefiting someone who's just starting to learn. I certainly would have appreciated this 6 months ago.


## 1. What does this model do?
This model compares the performance of a battery versus a hydrogen system for energy storage over the course of a year. 

## 2. How does this model work?
The model is set up in functional programming. There is a function for each of the components of the energy system (e.g. electrolyser_function.m). In addition, some interactions between these components are described in functions.

On the supply side, there are solar panels, wind turbine, and fuel cell. On the energy storage side, there is a battery, hydrogen tank, and electrolyser. 

The model simulates a year's worth of results in hourly timesteps, equating to 8760 hours. At each hour, it provides us with performance metrics of each component. Using a load-following strategy, the system performs a set of calculations, such as energy in vs out, state of charge of battery or hydrogen tank, or whether or not to turn on the electrolyser or fuel cell. 

## 3. How to run the code
Simply download the file and make sure you're in the correct folder path in matlab. Open the "main.m" file.

*Adjustable parameters:*   
* Line 4:    enter either "1" or "0" to determine which strategy the simulation will run. A battery priority strategy will use the battery as the main energy storage, and vice versa for the hydrogen priority strategy.  
* Line 10:   duration of simulation can be adjusted  
* Line 14:   hydrogen tank pressure at the start  
* Line 20:   state of charge at the start  
* Lines 94 & 101:   the output names of the excel files can be adjusted, e.g. "example.xlsx".  


## 4. What are some of the differences between the results of the original paper and this replication attempt?
Because the authors have not published their source code, differences will inevitably arise. Some assumptions had to be made. A detailed list of items is found in the word document "Differences.docx". 

Also, feel free to compare "battery_strategy_10.9.24.JPG" and "hydrogen_strategy_9.9.24.JPG" in the "Results" folder against figure 20 in the paper.

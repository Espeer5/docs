# Incorporating Hyperspectral Canopy into CliMALand
## 10 Week Project Schedule

### General Notes:
 - To avoid reinventing the wheel, largely this should be a process of porting Yujie's model to the rest of the Land. This means that most of the task here is the design work to understand how to integrate the model into the rest of the Land.

### Week 1
 - **Objective**: Software setup and planning
   - Gain access to required resources and outline a project plan

### Week 2
  - **Objective**: Map inputs and outputs of model and define requirements
    - A hyperspectral canopy will change the format of the inputs and outputs into the RT model
    - Must make design choices on how to handle the outputs - the rest of the Canopy usually ingests totals from the RT model, how should this change?
    - Inspect Yujie's model and define requirements for the new model to be compatible with the rest of the Land.

### Week 3-7
  - **Objective**: Implement simple hyperspectral model
    - This should be broken down into smaller subtasks with ongoing design work between stages
      1) Firstly, datastructures for the layers of the canopy should be intelligently designed
        - There is a discussion to be had here about the relationship with the layers in the hydraulics model
      2) A simplest case should be implemented first that essentially generalizes the current model to a set of layers
        - This should be tested against the current model to ensure that it is working correctly
        - This will be plugged to the rest of the model by summing and providing the same output as before
      3) Expand and improve the model and how it interacts with the rest of the Land

### Week 7-10
 - **Objective**: Source inputs data and test in simulation
    - Continue adding features to the model as possible
    - Collect/source input data for the model. Yujie's model pulls data from somewhere to run, and we will need to do the same to run sims with hyperspectral canopy.
    - Test the model against the current model and hopefully within global sims to validate
classdef MI_KSG_data
    %  MI_KSG_data is used to set up a data object with all of the data
    %  for a given recoring session
    % WE MAY WANT TO CHANGE PROPERTY NAMES TO GENERIC VARIABLES
    properties
        neurons % 1 x N array of spike timing vectors,[NOTE need to decide what units to use]
                % where N is the number of neurons recorded during this session. 
        pressure % 1 x N vector of the continuous pressure where N is the total samples
        breathTimes % 1 x N vector of onset times of each breath cycle
                    % where N is the total number of breath cycles
        Nbreaths % integer which indicates length of breathTimes
        pFs % sample frequency of pressure wave
        nFs % sample frequency of neural data  
    end

    methods
       function obj = MI_KSG_data(neurons, pressure, nFS,pFS)
           % This function inputs the neuron data  pressure data and the sample frequencies
          obj.neurons = neurons;
          obj.pressure = pressure;
          obj.pFs = pFS;
          obj.nFs = nFs;

       end

       function r = get_breathTimes()
	 % uses pressure wave and pFS to segment breaths into cycles and determines Nbreaths [NOTE BRYCES CODE MAY ALREADY DO THIS]
       end

       function r = databyCycles()
	 % Takes in neuron times or pressure wave, breath times, and nFs or pFs and makes a matrix of pressure cycles or spikes within cycles
           
       end
	 
   end
       
end

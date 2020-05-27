# -*- coding: utf-8 -*-
"""
Author: Mostafa Mirshekari
"""

import scipy.spatial as sp
import numpy as np


# A filtering-based approach for localization based on TDoA.
# In this version, I have considered a function with output of velocity at 
# different locations. In simple homogenous cases, a constant value can be assigned
# using the placeholder velocityFinder function.

# to localize, use the localizer_filter function.

# the following function is a placeholder for the velocity function.
def velocityFinder(x):
    # the velocity between the footstep and the six sensors.
    velocity = [5000] * 6
    return velocity
    


def toa_simulator_with_vel(boundary, grid_resolution, Sensor_Locations):
    # defining the mesh points for a given resolution.
    X = np.arange(boundary[0, 0], boundary[0, 1], grid_resolution)
    Y = np.arange(boundary[0, 2], boundary[0, 3], grid_resolution)

    # the combination of all the points in the mesh lists.
    loc_combinations = np.array([[x,y] for x in X for y in Y])

    # finding the distances between different combinations
    # the distances will have a shape of combination_no * number of sensors.
    distances = sp.distance.cdist(loc_combinations, Sensor_Locations, metric='euclidean')

    # finding the velocity array for each mesh point
    # this velocity: using a function with input = the location and output = velocity.
    # for each location and each sensor, one value of velocity should be produced.
    
    v_array = []
    for x, y in loc_combinations:
        v_array.append(velocityFinder([x, y]))
        
        
    #velocities = velocityFinder(model, likelihood, eval_locs)
    #v = np.array([velocities.reshape(1, -1)] * 6)
    #v_array = v.T.reshape(-1, 6)
    #print(np.unique(v_array))
        
    # dividing the distances by the velocities 
    # the output should be combination_no * number of sensors.
    sim_toa = np.divide(distances, v_array)

    # converting ToA to TDoA
    # reshaping is to enable broadcasting.
    sim_toa = np.subtract(sim_toa, sim_toa[:, 0].reshape(-1, 1))
    
    # return the TDoAs and the locations corresponding to them
    return sim_toa, loc_combinations

def toa_filter(TDoA, sim_toa, x_array, y_array, init_thresh = 0.0001, thresh_add = 0.0001):
    
    # Put the location combo info in two rows for the x and y 
    x_array = x_array.reshape(1, -1)
    y_array = y_array.reshape(1, -1)
    
    # TODO: layered filtering (remove elements in each row)
    # The current function goes through each row of the simulated TDoAs and 
    # finds the number of them that make sense given a threshold and assigns one to them.
    # summing the ones, we will find cases where all the TDoAs make sense.
    # if the number of solutions is less than a value, we increase the threshold and repeat.
    thresh = init_thresh
    number_of_sensors = len(sim_toa)
    num_of_solutions = 0
    
    while num_of_solutions < 10:
        temp_sim_toa = sim_toa
        filt_idx = np.zeros((1, sim_toa.shape[1]))
        for i in range(1, len(sim_toa)):
            temp_sim_toa = np.where((sim_toa[i, :] > TDoA[i]-thresh) & (sim_toa[i, :] < TDoA[i]+thresh), 1, 0)
            filt_idx += temp_sim_toa
        filt_idx = np.where(filt_idx >= number_of_sensors - 1, 1, 0) 
        num_of_solutions = np.sum(filt_idx)
        thresh = thresh + thresh_add
    
    filt_x = x_array[0][np.where(filt_idx == 1)[1]]
    filt_y = y_array[0][np.where(filt_idx == 1)[1]]
    
    return filt_x, filt_y, thresh

def localizer_filter(TDoA, boundary, grid_resolution, Sensor_Locations):
    sim_toa, loc_combinations = toa_simulator_with_vel(boundary, grid_resolution, Sensor_Locations)
    filt_x, filt_y, thresh = toa_filter(TDoA, sim_toa.T, loc_combinations[:, 0], loc_combinations[:, 1], init_thresh = 0.0001, thresh_add = 0.0001)
    return filt_x, filt_y, thresh

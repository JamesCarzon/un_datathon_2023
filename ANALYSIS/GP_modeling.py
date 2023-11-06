import numpy as np
import pandas as pd
import sklearn.gaussian_process as gp
import scipy
import matplotlib.pyplot as plt

data = pd.read_csv("/DATA/processed_data.csv", index_col=0)
data['elevation'] = 10*scipy.stats.norm.rvs(size=data.shape[0]) # Fake elevation values

kernel = gp.kernels.Matern(
  length_scale=[1.0]*5,
  length_scale_bounds=(10e-10, 10e10),
  nu=1.5
)

model = gp.GaussianProcessRegressor(
  kernel,
  optimizer='fmin_l_bfgs_b',
  random_state=2023
)

X = data[['latitude', 'longitude', 'popdens', 'elevation', 'plant_dist']].sample(1000, random_state=2023)
y = data[['NO2gm']].sample(1000, random_state=2023)

model.fit(X, y)
model.kernel_.get_params()


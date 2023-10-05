
@minLength(3)
@maxLength(24)
@description('A valid resource name must contains only letters and numbers')
param resourceName string

@allowed([ 'dev', 'test', 'stagging', 'prod'])
param environment string

@minValue(1)
@maxValue(5)
param instanceNumber int

param subnets array = ['10.10.0.1', '10.10.0.2', '10.10.0.3']

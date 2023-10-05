
/** Functions to work with arrays **/

@minLength(1)
@maxLength(20)
param fruits array = [
  'orange'
  'apple'
  'banana'
  'pinaple'
  'watermelon'
]

@minLength(1)
@maxLength(7)
param ages array = [
  79
  36
  35
  55
  30
  34
  32
]

@minLength(1)
@maxLength(7)
param firstnames array = [
  'Huber'
  'Samantha'
  'Sibila'
  'Marili'
  'Christian'
  'Gorby'
  'Carol'
]

@minLength(1)
@maxLength(7)
param lastnames array = [
  'Rivera'
  'Rivera'
  'Rivera'
  'Tello'
  'Rivera'
  'Rivera'
  'Santiago'
]

@minLength(1)
param devEngineers array = [
  'Christian'
  'Gian'
  'Jhonny'
  'Rodrich'
  'Marcel'
  'Wesley'
  'Santiago'
  'Jorge'
]

@minLength(1)
param cloudEngineers array = [
  'Javier'
  'Carlos'
  'Christian'
  'Gipo'
  'Rodrich'
]

@minLength(1)
param platformEngineers array = [
  'Kathir'
  'Prakash'
  'Syed'
  'Santiago'
  'Christian'
  'Javier'
]

@description('Represents the groups of software engineers profesionals')
param engineersGroup array[] = [
  devEngineers
  cloudEngineers
  platformEngineers
]


@description('Check whether if specific item is found in array, object or collection')
output containsOrange bool = contains(fruits, 'orange')
@description('Represents whether array, object or collection is empty')
output isEmpty bool = empty(fruits)
@description('Represents the first element in array or collection')
output firstElement string = first(fruits)
@description('Represents the last element in array or collection')
output lastElement string = last(fruits)
output sayHelloDevs array = map(devEngineers, dev => 'Hello ${dev} !')



@description('Represents the Dev and Cloud Enginners')
output concatDevAndCloudEngineers array = concat(devEngineers, cloudEngineers)
@description('Represents all software engineers')
output allEngineers array = flatten(engineersGroup)
@description('Represents all software engineers')
output engineers array = union(devEngineers, cloudEngineers, platformEngineers)
@description('Represents all engineers that are both Dev and Platform Engineers')
output onlyDevAndPlatformEngineers array = intersection(devEngineers, platformEngineers)
@description('Represents the first 2 Dev Engineers')
output firstTwoDevsChunk array = take(devEngineers, 2)
@description('Represents the last 2 Dev Engineers')
output lastTwoDevsChunk array = skip(devEngineers, length(devEngineers) - 2)


@description('Represents the max value in integer array or collection')
output maxAge int = max(ages)
@description('Represents the min value in integer array or collection')
output minAge int = min(ages)
@description('Give us the sum of ages')
output sumAges int = reduce(ages, 0, (current, nex) => current +  nex)
@description('Ages over 40')
output overForty array = filter(ages, age => age > 40)
@description('Returns sorted age')
output sortedAges array = sort(ages, (current, next) => next > current)

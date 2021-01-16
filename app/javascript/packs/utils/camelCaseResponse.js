import keysToCamel from '@utils/keysToCamel'

const camelCaseResponse = [
  (data) => keysToCamel(JSON.parse(data)),
]

export default camelCaseResponse

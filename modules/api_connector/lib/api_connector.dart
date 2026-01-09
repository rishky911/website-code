library api_connector;


class ApiConnector {
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Mock implementation
    // In a real app, this would use http or dio
    await Future.delayed(const Duration(milliseconds: 500));

    if (endpoint.contains('exchange_rates')) {
      return {
        'base': 'USD',
        'rates': {
          'EUR': 0.92,
          'GBP': 0.79,
          'JPY': 150.5,
          'INR': 83.2,
          'CAD': 1.36,
        }
      };
    }

    return {};
  }
}

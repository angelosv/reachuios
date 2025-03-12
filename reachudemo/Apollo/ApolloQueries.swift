import Foundation

// MARK: - GraphQL Queries
/// This file contains the GraphQL queries as raw strings
/// When Apollo is fully integrated, these will be replaced by generated code

struct ApolloQueries {
    
    // MARK: - Products Query
    static let productsQuery = """
    query GetProducts($limit: Int, $offset: Int, $category: String) {
      products(limit: $limit, offset: $offset, category: $category) {
        id
        title
        description
        images {
          id
          url
          order
        }
        price {
          currencyCode
          amount
          compareAtAmount
        }
        category
        variants {
          id
          title
          options {
            name
            value
          }
        }
        inventory {
          available
          isInStock
        }
      }
    }
    """
    
    // MARK: - Product Detail Query
    static let productDetailQuery = """
    query GetProductDetail($id: ID!) {
      product(id: $id) {
        id
        title
        description
        images {
          id
          url
          order
        }
        price {
          currencyCode
          amount
          compareAtAmount
        }
        category
        variants {
          id
          title
          options {
            name
            value
          }
        }
        inventory {
          available
          isInStock
        }
        relatedProducts {
          id
          title
          images {
            url
          }
          price {
            amount
            currencyCode
          }
        }
      }
    }
    """
    
    // MARK: - Categories Query
    static let categoriesQuery = """
    query GetCategories {
      categories {
        id
        name
        description
        image
        productCount
      }
    }
    """
    
    // MARK: - Search Products Query
    static let searchProductsQuery = """
    query SearchProducts($searchTerm: String!, $limit: Int, $offset: Int) {
      searchProducts(query: $searchTerm, limit: $limit, offset: $offset) {
        id
        title
        description
        images {
          id
          url
          order
        }
        price {
          currencyCode
          amount
          compareAtAmount
        }
        category
        inventory {
          isInStock
        }
      }
    }
    """
    
    // MARK: - Helper method to create a query with variables
    static func createQueryBody(query: String, variables: [String: Any]?) -> Data? {
        var body: [String: Any] = ["query": query]
        
        if let variables = variables {
            body["variables"] = variables
        }
        
        return try? JSONSerialization.data(withJSONObject: body, options: [])
    }
} 
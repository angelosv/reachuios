// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchProductsQuery: GraphQLQuery {
  public static let operationName: String = "SearchProducts"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchProducts { Channel { __typename GetProducts { __typename id title description images { __typename url order id } price { __typename currency_code amount compare_at } } } }"#
    ))

  public init() {}

  public struct Data: ReachuAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ReachuAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("Channel", Channel.self),
    ] }

    /// Entry point for querying products, categories, suppliers, and related entities.
    public var channel: Channel { __data["Channel"] }

    /// Channel
    ///
    /// Parent Type: `ProductsQueries`
    public struct Channel: ReachuAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ReachuAPI.Objects.ProductsQueries }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("GetProducts", [GetProduct].self),
      ] }

      /// Fetches a list of products based on the provided filters and context.
      public var getProducts: [GetProduct] { __data["GetProducts"] }

      /// Channel.GetProduct
      ///
      /// Parent Type: `Product`
      public struct GetProduct: ReachuAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ReachuAPI.Objects.Product }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Int.self),
          .field("title", String.self),
          .field("description", String?.self),
          .field("images", [Image].self),
          .field("price", Price.self),
        ] }

        /// Unique identifier for the product.
        public var id: Int { __data["id"] }
        /// Title of the product.
        public var title: String { __data["title"] }
        /// Description of the product.
        public var description: String? { __data["description"] }
        /// List of images for the product.
        public var images: [Image] { __data["images"] }
        /// Pricing details of the product.
        public var price: Price { __data["price"] }

        /// Channel.GetProduct.Image
        ///
        /// Parent Type: `Image`
        public struct Image: ReachuAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ReachuAPI.Objects.Image }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("url", String.self),
            .field("order", Int.self),
            .field("id", ReachuAPI.ID.self),
          ] }

          /// URL of the image.
          public var url: String { __data["url"] }
          /// Order in which the image is displayed.
          public var order: Int { __data["order"] }
          /// Unique identifier for the image.
          public var id: ReachuAPI.ID { __data["id"] }
        }

        /// Channel.GetProduct.Price
        ///
        /// Parent Type: `Price`
        public struct Price: ReachuAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ReachuAPI.Objects.Price }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("currency_code", String.self),
            .field("amount", Double.self),
            .field("compare_at", Double?.self),
          ] }

          /// Currency code in ISO 4217 format (e.g., "USD", "EUR").
          public var currency_code: String { __data["currency_code"] }
          /// Base amount of the price.
          public var amount: Double { __data["amount"] }
          /// Comparison price for the product.
          public var compare_at: Double? { __data["compare_at"] }
        }
      }
    }
  }
}

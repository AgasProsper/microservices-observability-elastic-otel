// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System;
using System.Threading.Tasks;
using Grpc.Core;
using Microsoft.Extensions.Logging;
using cartservice.cartstore;
using Hipstershop;
using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace cartservice.services
{
    public class CartService : Hipstershop.CartService.CartServiceBase
    {
        private readonly static Empty Empty = new Empty();
        private readonly ICartStore _cartStore;
        private static readonly ActivitySource _activitySource = new ActivitySource("cartservice");
        private static readonly Meter _meter = new Meter("cartservice");
        private static readonly Counter<int> _itemsAddedCounter = _meter.CreateCounter<int>("cart.items.added", description: "Number of items added to cart");

        public CartService(ICartStore cartStore)
        {
            _cartStore = cartStore;
        }

        public async override Task<Empty> AddItem(AddItemRequest request, ServerCallContext context)
        {
            using var activity = _activitySource.StartActivity("AddItem.AddToCart");
            activity?.SetTag("user.id", request.UserId);
            activity?.SetTag("product.id", request.Item.ProductId);
            activity?.SetTag("product.quantity", request.Item.Quantity);

            await _cartStore.AddItemAsync(request.UserId, request.Item.ProductId, request.Item.Quantity);
            
            _itemsAddedCounter.Add(request.Item.Quantity);
            return Empty;
        }

        public override Task<Cart> GetCart(GetCartRequest request, ServerCallContext context)
        {
            using var activity = _activitySource.StartActivity("GetCart.FetchContents");
            activity?.SetTag("user.id", request.UserId);
            return _cartStore.GetCartAsync(request.UserId);
        }

        public async override Task<Empty> EmptyCart(EmptyCartRequest request, ServerCallContext context)
        {
            await _cartStore.EmptyCartAsync(request.UserId);
            return Empty;
        }
    }
}